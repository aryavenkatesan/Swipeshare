from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel


class ListingCreateDto(BaseModel):
    seller_id: str
    dining_hall: Literal["Chase", "Lenoir"]
    time_start: int
    time_end: int
    transaction_date: datetime


class ListingDto(ListingCreateDto):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            seller_id=data["sellerId"],
            dining_hall=data["diningHall"],
            time_start=data["timeStart"],
            time_end=data["timeEnd"],
            transaction_date=data["transactionDate"],
        )
