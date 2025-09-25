import asyncio
from datetime import datetime

from core.config import CHAT_QUEUE_SIZE
from database import get_db, get_sync_db
from fastapi import Depends
from google.cloud.firestore import AsyncClient, Client
from modules.message.message_model import MessageCreate, MessageData, MessageDto
from modules.message.message_queue_service import MessageQueueManager, MessageQueueRegistry
from modules.order.order_service import OrderNotFoundException
from modules.user.user_model import UserDto
from modules.user.user_service import UserService


class MessageService:
    def __init__(
        self,
        db: AsyncClient = Depends(get_db),
        sync_db: Client = Depends(get_sync_db),
        user_service: UserService = Depends(),
        queue_registry: MessageQueueRegistry = Depends(),
    ):
        self.order_collection = db.collection("orders")
        self.sync_order_collection = sync_db.collection("orders")

        self.user_service = user_service

        self.queue_managers = queue_registry.queue_managers
        self._queue_lock = queue_registry.lock

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
        async with self._queue_lock:
            if order_id not in self.queue_managers:
                queue = asyncio.Queue(maxsize=CHAT_QUEUE_SIZE)
                sync_order_doc_ref = self.sync_order_collection.document(order_id)
                messages_ref = sync_order_doc_ref.collection("messages")

                listener = messages_ref.on_snapshot(
                    self.snapshot_listener_for_queue(queue)
                )
                self.queue_managers[order_id] = MessageQueueManager(
                    queue=queue, listener=listener
                )
            else:
                self.queue_managers[order_id].increment_refs()
            return self.queue_managers[order_id].queue

    async def cleanup_message_queue(self, order_id: str) -> bool:
        async with self._queue_lock:
            if order_id not in self.queue_managers:
                return False

            manager = self.queue_managers[order_id]
            manager.decrement_refs()

            if manager.has_refs():
                return False

            self.queue_managers.pop(order_id)
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
