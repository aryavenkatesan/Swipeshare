from core.authentication import authenticate_user
from fastapi import APIRouter, Depends, HTTPException, Request
from modules.order.order_service import OrderService
from modules.user.user_model import UserDto
from modules.user.user_service import UserService

from .order_model import (
    OrderCreate,
    OrderData,
    OrderDto,
    TransactionCreate,
)

order_router = APIRouter(prefix="/api/orders")


@order_router.post(
    "/",
    status_code=201,
    response_model=OrderDto,
    description="Create a new order with the current user as the buyer",
)
async def create_order(
    order_data: OrderCreate,
    order_service: OrderService = Depends(),
    user_service: UserService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> OrderDto:
    if order_data.seller_id == user.id:
        raise HTTPException(400, "You cannot create an order for your own listing")
    
    if not await user_service.user_with_id_exists(order_data.seller_id):
        raise HTTPException(404, f"User with id {order_data.seller_id} not found")

    with_buyer = OrderData(
        seller_id=order_data.seller_id,
        buyer_id=user.id,
        dining_hall=order_data.dining_hall,
        transaction_datetime=order_data.transaction_datetime,
    )
    return await order_service.create_order(with_buyer)


@order_router.post(
    "/consume-listing/{listing_id}",
    status_code=201,
    response_model=OrderDto,
    description="Create a new order based on an existing listing, with the current user as the buyer, deleting the listing upon creation",
)
async def make_transaction(
    listing_id: str,
    transaction_data: TransactionCreate,
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
):
    return await order_service.make_transaction(listing_id, user.id, transaction_data)


@order_router.get(
    "/",
    response_model=list[OrderDto],
    description="Get a list of all orders with the current user as the buyer, with query params as optional filters",
)
async def get_orders(
    request: Request,
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> list[OrderDto]:
    filters = {**request.query_params, "buyer_id": user.id}
    return await order_service.get_orders(filters)


@order_router.get(
    "/{order_id}",
    response_model=OrderDto,
    description="Get a specific order associated with the current user by id",
)
async def get_order_by_id(
    order_id: str,
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> OrderDto:
    order = await order_service.get_order_by_id(order_id)
    if order.buyer_id != user.id:
        raise HTTPException(403, "You are not allowed to access this order")
    return order


@order_router.delete(
    "/{order_id}",
    response_model=OrderDto,
    description="Delete an order associated with the current user by id",
)
async def delete_order(
    order_id: str,
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> OrderDto:
    return await order_service.delete_order_for_user(user.id, order_id)
