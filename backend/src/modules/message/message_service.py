import asyncio
from datetime import datetime

from core.config import CHAT_QUEUE_SIZE
from database import get_db, get_sync_db
from fastapi import Depends
from google.cloud.firestore import AsyncClient, Client
from modules.message.message_model import MessageCreate, MessageData, MessageDto
from modules.message.message_queue_manager import MessageQueueManager
from modules.order.order_service import OrderNotFoundException
from modules.user.user_model import UserDto
from modules.user.user_service import UserService

_queue_lock = asyncio.Lock()


queue_managers: dict[str, MessageQueueManager] = {}

class QueueRegistry:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.queues = {}
        self.lock = asyncio.Lock()


class MessageService:
    def __init__(
        self,
        db: AsyncClient = Depends(get_db),
        sync_db: Client = Depends(get_sync_db),
        user_service: UserService = Depends(),
        queue_registry: QueueRegistry = Depends(),
    ):
        self.db = db
        self.sync_db = sync_db
        self.order_collection = db.collection("orders")
        self.sync_order_collection = sync_db.collection("orders")
        self.user_service = user_service
        self.

    def snapshot_listener_for_queue(self, message_queue: asyncio.Queue[MessageDto]):
        def on_snapshot(doc_snapshot, changes, read_time):
            for change in changes:
                if change.type.name == "ADDED":
                    doc_data = change.document.to_dict()
                    message = MessageDto(
                        id=change.document.id,
                        content=doc_data.get("content"),
                        sender_id=doc_data.get("sender_id"),
                        sender_email=doc_data.get("sender_email"),
                        timestamp=doc_data.get("timestamp"),
                    )
                    try:
                        # Put synchronously to avoid issues with Firestore's sync listener
                        message_queue.put_nowait(message)
                    except asyncio.QueueFull:
                        print(f"Queue is full, cannot add message: {message.id}")
                        raise

        return on_snapshot

    async def get_message_queue(self, order_id: str) -> asyncio.Queue[MessageDto]:
        async with _queue_lock:
            if order_id not in queue_managers:
                queue = asyncio.Queue(maxsize=CHAT_QUEUE_SIZE)
                sync_order_doc_ref = self.sync_order_collection.document(order_id)
                messages_ref = sync_order_doc_ref.collection("messages")

                listener = messages_ref.on_snapshot(
                    self.snapshot_listener_for_queue(queue)
                )
                queue_managers[order_id] = MessageQueueManager(
                    queue=queue, listener=listener
                )
            else:
                queue_managers[order_id].increment_refs()
            return queue_managers[order_id].queue

    async def cleanup_message_queue(self, order_id: str) -> bool:
        async with _queue_lock:
            if order_id not in queue_managers:
                return False

            manager = queue_managers[order_id]
            manager.decrement_refs()

            if manager.has_refs():
                return False

            queue_managers.pop(order_id)
            manager.dispose_listener()
            return True

    async def add_message_to_order(
        self, data: MessageCreate, order_id: str, sender: UserDto
    ) -> MessageDto:
        """
        Note: This method assumes the sender has already been authenticated and validated.
        """
        order_ref = self.order_collection.document(order_id)

        order_doc = await order_ref.get()
        if not order_doc.exists:
            raise OrderNotFoundException(f"Order with id {order_id} does not exist")

        message_ref = order_ref.collection("messages").document()
        message = MessageData(
            content=data.content,
            sender_id=sender.id,
            sender_email=sender.email,
            timestamp=datetime.now(),
        )
        await message_ref.set(message.model_dump())
        return MessageDto.from_doc(await message_ref.get())

    @classmethod
    async def cleanup_all_listeners(cls):
        async with _queue_lock:
            for manager in queue_managers.values():
                manager.dispose_listener()

            queue_managers.clear()
            print("All message queue listeners have been cleaned up.")
