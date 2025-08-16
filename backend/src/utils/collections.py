from database import db
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference


def get_order_collection() -> AsyncCollectionReference:
    return db.collection("orders")


def get_user_collection() -> AsyncCollectionReference:
    return db.collection("users")


def get_listing_collection() -> AsyncCollectionReference:
    return db.collection("listings")
