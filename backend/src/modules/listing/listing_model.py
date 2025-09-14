from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel

class ListingCreate(BaseModel):
    dining_hall: Literal["Chase", "Lenoir"]
    time_start: int
    time_end: int
    transaction_date: datetime


class ListingData(BaseModel):
    seller_id: str
    dining_hall: Literal["Chase", "Lenoir"]
    time_start: int
    time_end: int
    transaction_date: datetime


class ListingDto(ListingData):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if not doc.exists or data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            seller_id=data["seller_id"],
            dining_hall=data["dining_hall"],
            time_start=data["time_start"],
            time_end=data["time_end"],
            transaction_date=data["transaction_date"],
        )
