from database import get_db
from fastapi import Depends
from google.cloud import firestore
from google.cloud.firestore import AsyncClient, AsyncTransaction, FieldFilter
from modules.listing.listing_model import ListingDto
from modules.listing.listing_service import ListingNotFoundException
from modules.order.order_model import OrderData, OrderDto, TransactionCreate
from core.exceptions import ForbiddenException, NotFoundException


class OrderNotFoundException(NotFoundException):
    pass


class OrderService:
    def __init__(self, db: AsyncClient = Depends(get_db)):
        self.db = db
        self.order_collection = db.collection("orders")
        self.listing_collection = db.collection("listings")

    async def create_order(self, order_data: OrderData) -> OrderDto:
        order_ref = self.order_collection.document()
        await order_ref.set(order_data.model_dump())
        return OrderDto.from_doc(await order_ref.get())

    async def get_orders(self, filters: dict[str, str]) -> list[OrderDto]:
        query = self.order_collection
        for field, value in filters.items():
            query = query.where(filter=FieldFilter(field, "==", value))
        docs = query.stream()
        return [OrderDto.from_doc(doc) async for doc in docs]

    async def get_order_by_id(self, order_id: str) -> OrderDto:
        doc = await self.order_collection.document(order_id).get()
        if not doc.exists:
            raise OrderNotFoundException(f"Order with id {order_id} not found")
        return OrderDto.from_doc(doc)

    async def delete_order_for_user(self, user_id: str, order_id: str) -> OrderDto:
        order_ref = self.order_collection.document(order_id)
        doc = await order_ref.get()
        if not doc.exists:
            raise OrderNotFoundException(f"Order with id {order_id} not found")
        order = OrderDto.from_doc(doc)
        if order.buyer_id != user_id:
            raise ForbiddenException("You are not allowed to delete this order")
        await order_ref.delete()
        return OrderDto.from_doc(doc)

    async def make_transaction(
        self,
        listing_id: str,
        user_id: str,
        transaction_data: TransactionCreate,
    ) -> OrderDto:
        listing_doc_ref = self.listing_collection.document(listing_id)
        order_doc_ref = self.order_collection.document()

        @firestore.async_transactional
        async def attempt_transaction(transaction: AsyncTransaction):
            listing_doc = await listing_doc_ref.get(transaction=transaction)
            if not listing_doc.exists:
                raise ListingNotFoundException(
                    f"Listing with id {listing_id} not found"
                )
            listing = ListingDto.from_doc(listing_doc)
            order_data = OrderData(
                seller_id=listing.seller_id,
                buyer_id=user_id,
                dining_hall=listing.dining_hall,
                transaction_datetime=transaction_data.transaction_datetime,
            )
            transaction.create(order_doc_ref, order_data.model_dump())
            transaction.delete(listing_doc_ref)

        await attempt_transaction(self.db.transaction())
        return OrderDto.from_doc(await order_doc_ref.get())
