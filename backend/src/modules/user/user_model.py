from typing import Self

from google.cloud.firestore import DocumentSnapshot
from pydantic import BaseModel, EmailStr


class UserCreateDto(BaseModel):
    email: EmailStr
    password: str


class UserDto(BaseModel):
    id: str
    email: EmailStr

    @classmethod
    def from_doc(cls, doc: DocumentSnapshot) -> Self:
        data = doc.to_dict()

        if data is None:
            raise ValueError("Invalid document snapshot")

        return cls(id=doc.id, email=data["email"])
