from core.authentication import authenticate_user
from fastapi import APIRouter, Depends, Request
from modules.listing.listing_service import ListingService
from modules.user.user_model import UserDto

from .listing_model import ListingCreate, ListingData, ListingDto

listing_router = APIRouter(prefix="/api/listings")


@listing_router.post(
    "/",
    status_code=201,
    response_model=ListingDto,
    description="Create a new listing with the current user as the seller",
)
async def create_listing(
    listing_data: ListingCreate,
    listing_service: ListingService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> ListingDto:
    with_seller = ListingData(
        seller_id=user.id,
        dining_hall=listing_data.dining_hall,
        time_start=listing_data.time_start,
        time_end=listing_data.time_end,
        transaction_date=listing_data.transaction_date,
    )
    return await listing_service.create_listing(with_seller)


@listing_router.get(
    "/",
    response_model=list[ListingDto],
    description="Get a list of all listings, with query params as filters",
)
async def get_listings(
    request: Request,
    listing_service: ListingService = Depends(),
    _=Depends(authenticate_user),
) -> list[ListingDto]:
    filters = dict(request.query_params)
    return await listing_service.get_listings(filters)


@listing_router.get("/{listing_id}", response_model=ListingDto)
async def get_listing_by_id(
    listing_id: str,
    listing_service: ListingService = Depends(),
    _=Depends(authenticate_user),
) -> ListingDto:
    return await listing_service.get_listing_by_id(listing_id)


@listing_router.put(
    "/{listing_id}",
    response_model=ListingDto,
    description="Update an existing listing associated with the current user",
)
async def update_listing(
    listing_id: str,
    listing_data: ListingCreate,
    listing_service: ListingService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> ListingDto:
    with_seller = ListingData(
        seller_id=user.id,
        dining_hall=listing_data.dining_hall,
        time_start=listing_data.time_start,
        time_end=listing_data.time_end,
        transaction_date=listing_data.transaction_date,
    )
    return await listing_service.update_listing_for_user(
        user.id, listing_id, with_seller
    )


@listing_router.delete(
    "/{listing_id}",
    response_model=ListingDto,
    description="Delete a listing associated with the current user",
)
async def delete_listing(
    listing_id: str,
    listing_service: ListingService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> ListingDto:
    return await listing_service.delete_listing_for_user(user.id, listing_id)
