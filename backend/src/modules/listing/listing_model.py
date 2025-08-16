from datetime import datetime
from typing import Literal, Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel


class ListingCreateDto(BaseModel):
    sellerId: str
    diningHall: Literal["Chase", "Lenoir"]
    timeStart: int
    timeEnd: int
    transactionDate: datetime


class ListingDto(ListingCreateDto):
    id: str

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()
        if data is None:
            raise ValueError("Invalid document snapshot")
        return cls(
            id=doc.id,
            sellerId=data["sellerId"],
            diningHall=data["diningHall"],
            timeStart=data["timeStart"],
            timeEnd=data["timeEnd"],
            transactionDate=data["transactionDate"],
        )
