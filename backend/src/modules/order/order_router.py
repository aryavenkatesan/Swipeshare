from core.security.authentication import authenticate_user
from fastapi import APIRouter, Depends, HTTPException
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from modules.user.user_service import user_exists
from utils.collections import get_order_collection, get_user_collection

from .order_model import OrderCreateDto, OrderDto

order_router = APIRouter(prefix="/orders", dependencies=[Depends(authenticate_user)])


@order_router.post("/", status_code=201, response_model=OrderDto)
async def create_order(
    order_data: OrderCreateDto,
    order_collection: AsyncCollectionReference = Depends(get_order_collection),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> OrderDto:
    if not await user_exists(order_data.seller_id, user_collection):
        raise HTTPException(404, f"Seller with id {order_data.seller_id} not found")
    if not await user_exists(order_data.buyer_id, user_collection):
        raise HTTPException(404, f"Buyer with id {order_data.buyer_id} not found")

    order_ref = order_collection.document()
    await order_ref.set(order_data.model_dump())
    return OrderDto.from_doc(await order_ref.get())


@order_router.get("/", response_model=list[OrderDto])
async def get_all_orders(
    order_collection: AsyncCollectionReference = Depends(get_order_collection),
) -> list[OrderDto]:
    docs = order_collection.stream()
    return [OrderDto.from_doc(doc) async for doc in docs]


@order_router.get("/{order_id}", response_model=OrderDto)
async def get_order_by_order_id(
    order_id: str,
    order_collection: AsyncCollectionReference = Depends(get_order_collection),
) -> OrderDto:
    doc = await order_collection.document(order_id).get()
    if not doc.exists:
        raise HTTPException(404, f"Order with id {order_id} not found")
    return OrderDto.from_doc(doc)


@order_router.put("/{order_id}", response_model=OrderDto)
async def update_order(
    order_id: str,
    order_data: OrderCreateDto,
    order_collection: AsyncCollectionReference = Depends(get_order_collection),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> OrderDto:
    order_ref = order_collection.document(order_id)
    doc = await order_ref.get()
    current_data = doc.to_dict()
    if not doc.exists or current_data is None:
        raise HTTPException(404, f"Order with id {order_id} not found")

    if order_data.seller_id != current_data.get("sellerId"):
        if not await user_exists(order_data.seller_id, user_collection):
            raise HTTPException(404, f"Seller with id {order_data.seller_id} not found")

    if order_data.buyer_id != current_data.get("buyerId"):
        if not await user_exists(order_data.buyer_id, user_collection):
            raise HTTPException(404, f"Buyer with id {order_data.buyer_id} not found")

    await order_ref.set(order_data.model_dump())
    return OrderDto.from_doc(await order_ref.get())


@order_router.delete("/{order_id}", response_model=OrderDto)
async def delete_order(
    order_id: str,
    order_collection: AsyncCollectionReference = Depends(get_order_collection),
) -> OrderDto:
    order_ref = order_collection.document(order_id)
    doc = await order_ref.get()
    if not doc.exists:
        raise HTTPException(404, f"Order with id {order_id} not found")
    await order_ref.delete()
    return OrderDto.from_doc(doc)
