from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel


class OrderCreate(BaseModel):
    seller_id: str
    dining_hall: Literal["Chase", "Lenoir"]
    transaction_datetime: datetime


class TransactionCreate(BaseModel):
    transaction_datetime: datetime


class OrderData(BaseModel):
    seller_id: str
    buyer_id: str
    dining_hall: Literal["Chase", "Lenoir"]
    transaction_datetime: datetime


class OrderDto(OrderData):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if not doc.exists or data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            seller_id=data["seller_id"],
            buyer_id=data["buyer_id"],
            dining_hall=data["dining_hall"],
            transaction_datetime=data["transaction_datetime"],
        )
