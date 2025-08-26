from core.security.authentication import authenticate_user
from fastapi import APIRouter, Depends, HTTPException, Request
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from modules.auth.auth_service import get_password_hash
from modules.user.user_model import UserCreateDto, UserDto
from utils.collections import get_user_collection

user_router = APIRouter(prefix="/users", dependencies=[Depends(authenticate_user)])


@user_router.post("/", status_code=201, response_model=UserDto)
async def create_user(
    user_data: UserCreateDto,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    user_ref = user_collection.document()
    user_data.password = get_password_hash(user_data.password)
    await user_ref.set(user_data.model_dump())
    return UserDto.from_doc(await user_ref.get())


@user_router.get("/", response_model=list[UserDto])
async def get_users(
    request: Request,
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> list[UserDto]:
    filters = dict(request.query_params)
    query = user_collection
    for field, value in filters.items():
        query = query.where(field, "==", value)
    docs = query.stream()
    return [UserDto.from_doc(doc) async for doc in docs]


@user_router.get("/me", response_model=UserDto)
async def get_current_user(user: UserDto = Depends(authenticate_user)) -> UserDto:
    return user


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
