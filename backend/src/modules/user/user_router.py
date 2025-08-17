from fastapi import APIRouter, Depends, HTTPException
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from modules.user.user_model import UserCreateDto, UserDto
from utils.collections import get_user_collection

user_router = APIRouter(prefix="/users")


@user_router.post("/", status_code=201, response_model=UserDto)
async def create_user(
    user_data: UserCreateDto,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    user_ref = user_collection.document()
    await user_ref.set(user_data.model_dump())
    return UserDto.from_doc(await user_ref.get())


@user_router.get("/", response_model=list[UserDto])
async def get_all_users(
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> list[UserDto]:
    docs = user_collection.stream()
    return [UserDto.from_doc(doc) async for doc in docs]


@user_router.get("/{user_id}", response_model=UserDto)
async def get_user_by_id(
    user_id: str,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    doc = await user_collection.document(user_id).get()
    if not doc.exists:
        raise HTTPException(404, f"User with id {user_id} not found")
    return UserDto.from_doc(doc)


@user_router.put("/{user_id}", response_model=UserDto)
async def update_user(
    user_id: str,
    user_data: UserCreateDto,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    user_ref = user_collection.document(user_id)
    doc = await user_ref.get()
    if not doc.exists:
        raise HTTPException(404, f"User with id {user_id} not found")
    await user_ref.set(user_data.model_dump())
    return UserDto.from_doc(await user_ref.get())


@user_router.delete("/{user_id}", response_model=UserDto)
async def delete_user(
    user_id: str,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    user_ref = user_collection.document(user_id)
    doc = await user_ref.get()
    if not doc.exists:
        raise HTTPException(404, f"User with id {user_id} not found")
    await user_ref.delete()
    return UserDto.from_doc(doc)
