from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel


class OrderCreateDto(BaseModel):
    seller_id: str
    buyer_id: str
    dining_hall: Literal["Chase", "Lenoir"]
    transaction_datetime: datetime


class OrderDto(OrderCreateDto):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            seller_id=data["sellerId"],
            buyer_id=data["buyerId"],
            dining_hall=data["diningHall"],
            transaction_datetime=data["transactionDatetime"],
        )
