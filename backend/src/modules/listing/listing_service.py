from core.exceptions import ForbiddenException, NotFoundException
from database import get_db
from fastapi import Depends
from google.cloud.firestore import AsyncClient, FieldFilter
from modules.listing.listing_model import ListingData, ListingDto


class ListingNotFoundException(NotFoundException):
    pass


class ListingService:
    def __init__(self, db: AsyncClient = Depends(get_db)):
        self.listing_collection = db.collection("listings")

    async def create_listing(self, listing_data: ListingData) -> ListingDto:
        listing_ref = self.listing_collection.document()
        await listing_ref.set(listing_data.model_dump())
        return ListingDto.from_doc(await listing_ref.get())

    async def get_listings(self, filters: dict[str, str]):
        query = self.listing_collection
        for field, value in filters.items():
            query = query.where(filter=FieldFilter(field, "==", value))
        docs = query.stream()
        return [ListingDto.from_doc(doc) async for doc in docs]

    async def get_listing_by_id(self, listing_id: str) -> ListingDto:
        doc = await self.listing_collection.document(listing_id).get()
        if not doc.exists:
            raise ListingNotFoundException(f"Listing with id {listing_id} not found")
        return ListingDto.from_doc(doc)

    async def update_listing_for_user(
        self, user_id: str, listing_id: str, listing_data: ListingData
    ) -> ListingDto:
        if listing_data.seller_id != user_id:
            raise ForbiddenException(
                "You are not allowed to update this listing to a different seller"
            )

        listing_ref = self.listing_collection.document(listing_id)
        doc = await listing_ref.get()
        current_data = doc.to_dict()
        if not doc.exists or current_data is None:
            raise ListingNotFoundException(f"Listing with id {listing_id} not found")

        if current_data.get("seller_id") != user_id:
            raise ForbiddenException(
                "You are not allowed to update a listing for this seller"
            )

        await listing_ref.set(listing_data.model_dump())
        return ListingDto.from_doc(await listing_ref.get())

    async def delete_listing(self, listing_id: str) -> ListingDto:
        listing_ref = self.listing_collection.document(listing_id)
        doc = await listing_ref.get()
        if not doc.exists:
            raise ListingNotFoundException(f"Listing with id {listing_id} not found")
        await listing_ref.delete()
        return ListingDto.from_doc(doc)

    async def delete_listing_for_user(
        self, user_id: str, listing_id: str
    ) -> ListingDto:
        listing_ref = self.listing_collection.document(listing_id)
        doc = await listing_ref.get()
        if not doc.exists:
            raise ListingNotFoundException(f"Listing with id {listing_id} not found")

        listing = ListingDto.from_doc(doc)
        if listing.seller_id != user_id:
            raise ForbiddenException("You are not allowed to delete this listing")

        await listing_ref.delete()
        return listing
