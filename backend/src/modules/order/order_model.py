from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel


class OrderCreateDto(BaseModel):
    sellerId: str
    buyerId: str
    diningHall: Literal["Chase", "Lenoir"]
    transactionDatetime: datetime


class OrderDto(OrderCreateDto):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            sellerId=data["sellerId"],
            buyerId=data["buyerId"],
            diningHall=data["diningHall"],
            transactionDatetime=data["transactionDatetime"],
        )
