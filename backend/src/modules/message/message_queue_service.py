import asyncio

from core.config import CHAT_QUEUE_SIZE
from google.cloud.firestore_v1.watch import Watch
from modules.message.message_model import MessageDto


class MessageQueueRegistry:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.queue_managers: dict[str, MessageQueueManager] = {}
        self.lock = asyncio.Lock()

    async def cleanup_all_listeners(self):
        async with self.lock:
            for manager in self.queue_managers.values():
                manager.dispose_listener()


class MessageQueueManager:
    def __init__(
        self,
        queue: asyncio.Queue[MessageDto] | None = None,
        *,
        listener: Watch,
    ):
        self.queue = queue or asyncio.Queue(maxsize=CHAT_QUEUE_SIZE)
        self.ref_count = 0
        self.listener = listener

    def increment_refs(self):
        self.ref_count += 1

    def decrement_refs(self):
        if self.has_refs():
            self.ref_count -= 1

    def has_refs(self) -> bool:
        return self.ref_count > 0

    def dispose_listener(self):
        self.listener.unsubscribe()
