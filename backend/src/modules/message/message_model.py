from datetime import datetime
from typing import Self

from pydantic import BaseModel, EmailStr


class MessageCreate(BaseModel):
    content: str


class MessageData(BaseModel):
    content: str
    sender_id: str
    sender_email: EmailStr
    timestamp: datetime


class MessageDto(MessageData):
    id: str

    @classmethod
    def from_doc(cls, doc) -> Self:
        data = doc.to_dict()
        if not doc.exists or data is None:
            raise ValueError("Invalid document snapshot")
        return cls.from_dict({"id": doc.id, **data})

    @classmethod
    def from_dict(cls, data: dict) -> Self:
        return cls(
            id=data["id"],
            content=data["content"],
            sender_email=data["sender_email"],
            sender_id=data["sender_id"],
            timestamp=data["timestamp"],
        )
