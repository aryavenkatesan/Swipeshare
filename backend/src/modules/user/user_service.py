from database import get_db
from fastapi import Depends
from google.cloud.firestore import AsyncClient
from modules.auth.auth_service import get_password_hash
from modules.user.user_model import UserCreate, UserDto
from core.exceptions import ConflictException, NotFoundException


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

    async def get_user_by_email(self, email: str) -> UserDto:
        query = self.user_collection.where("email", "==", email).limit(1)
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

    async def get_hashed_password(self, email: str) -> str:
        query = self.user_collection.where("email", "==", email).limit(1)
        user, *_ = await query.get()
        if user is None or not user.exists:
            raise UserNotFoundException(f"User with email {email} not found")
        password = user.get("password")
        if password is None:
            raise UserPasswordNotSetException(
                f"User with email {email} has no password set"
            )
        return password
