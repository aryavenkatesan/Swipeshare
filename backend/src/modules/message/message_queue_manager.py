import asyncio

from core.config import CHAT_QUEUE_SIZE
from google.cloud.firestore_v1.watch import Watch
from modules.message.message_model import MessageDto


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
