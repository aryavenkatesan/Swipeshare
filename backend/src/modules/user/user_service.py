from core.exceptions import ConflictException, NotFoundException
from database import get_db
from fastapi import Depends
from google.cloud.firestore import AsyncClient, FieldFilter
from modules.auth.auth_service import get_password_hash
from modules.user.user_model import UserCreate, UserDto


class UserConflictException(ConflictException):
    pass


class UserNotFoundException(NotFoundException):
    pass


class UserPasswordNotSetException(NotFoundException):
    pass


class UserService:
    def __init__(self, db: AsyncClient = Depends(get_db)):
        self.user_collection = db.collection("users")

    async def create_user(self, user_data: UserCreate) -> UserDto:
        if await self.user_with_email_exists(user_data.email):
            raise UserConflictException(
                detail=f"User with email {user_data.email} already exists"
            )

        user_ref = self.user_collection.document()
        user_data.password = get_password_hash(user_data.password)
        await user_ref.set(user_data.model_dump())
        return UserDto.from_doc(await user_ref.get())

    async def get_all_users(self) -> list[UserDto]:
        docs = self.user_collection.stream()
        return [UserDto.from_doc(doc) async for doc in docs]

    async def get_user_by_email(self, email: str) -> UserDto:
        query = self.user_collection.where(
            filter=FieldFilter("email", "==", email)
        ).limit(1)
        users = await query.get()
        if not users or not users[0].exists:
            raise UserNotFoundException(f"User with email {email} not found")
        return UserDto.from_doc(users[0])

    async def user_with_email_exists(self, email: str) -> bool:
        try:
            await self.get_user_by_email(email)
            return True
        except UserNotFoundException:
            return False

    async def user_with_id_exists(self, user_id: str) -> bool:
        doc = await self.user_collection.document(user_id).get()
        return doc.exists

    async def user_exists(
        self, id: str | None = None, email: str | None = None
    ) -> bool:
        if id is not None and email is not None:
            raise ValueError("Only one of user_id or email should be provided")
        if id is not None:
            return await self.user_with_id_exists(id)
        elif email is not None:
            return await self.user_with_email_exists(email)
        else:
            raise ValueError("Either user_id or email must be provided")

    async def get_hashed_password(self, email: str) -> str:
        query = self.user_collection.where(
            filter=FieldFilter("email", "==", email)
        ).limit(1)
        users = await query.get()
        if not users or not users[0].exists:
            raise UserNotFoundException(f"User with email {email} not found")
        password = users[0].get("password")
        if password is None:
            raise UserPasswordNotSetException(
                f"User with email {email} has no password set"
            )
        return password
