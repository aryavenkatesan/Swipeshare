from fastapi import APIRouter, Depends, HTTPException
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from modules.user.user_service import user_exists
from utils.collections import get_listing_collection, get_user_collection

from .listing_model import ListingCreateDto, ListingDto

listing_router = APIRouter(prefix="/listings")


@listing_router.post("/", status_code=201, response_model=ListingDto)
async def create_listing(
    listing_data: ListingCreateDto,
    listing_collection: AsyncCollectionReference = Depends(get_listing_collection),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> ListingDto:
    if not await user_exists(listing_data.sellerId, user_collection):
        raise HTTPException(404, f"Seller with id {listing_data.sellerId} not found")
    listing_ref = listing_collection.document()
    await listing_ref.set(listing_data.model_dump())
    return ListingDto.from_doc(await listing_ref.get())


@listing_router.get("/", response_model=list[ListingDto])
async def get_all_listings(
    listing_collection: AsyncCollectionReference = Depends(get_listing_collection),
) -> list[ListingDto]:
    docs = listing_collection.stream()
    return [ListingDto.from_doc(doc) async for doc in docs]


@listing_router.get("/{listing_id}", response_model=ListingDto)
async def get_listing_by_id(
    listing_id: str,
    listing_collection: AsyncCollectionReference = Depends(get_listing_collection),
) -> ListingDto:
    doc = await listing_collection.document(listing_id).get()
    if not doc.exists:
        raise HTTPException(404, f"Listing with id {listing_id} not found")
    return ListingDto.from_doc(doc)


@listing_router.put("/{listing_id}", response_model=ListingDto)
async def update_listing(
    listing_id: str,
    listing_data: ListingCreateDto,
    listing_collection: AsyncCollectionReference = Depends(get_listing_collection),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> ListingDto:
    listing_ref = listing_collection.document(listing_id)
    doc = await listing_ref.get()
    current_data = doc.to_dict()
    if not doc.exists or current_data is None:
        raise HTTPException(404, f"Listing with id {listing_id} not found")
    if listing_data.sellerId != current_data.get("sellerId"):
        if not await user_exists(listing_data.sellerId, user_collection):
            raise HTTPException(
                404, f"Seller with id {listing_data.sellerId} not found"
            )
    await listing_ref.set(listing_data.model_dump())
    return ListingDto.from_doc(await listing_ref.get())


@listing_router.delete("/{listing_id}", response_model=ListingDto)
async def delete_listing(
    listing_id: str,
    listing_collection: AsyncCollectionReference = Depends(get_listing_collection),
) -> ListingDto:
    listing_ref = listing_collection.document(listing_id)
    doc = await listing_ref.get()
    if not doc.exists:
        raise HTTPException(404, f"Listing with id {listing_id} not found")
    await listing_ref.delete()
    return ListingDto.from_doc(doc)
