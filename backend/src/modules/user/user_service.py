from database import db


async def user_exists(user_id: str, user_collection=None) -> bool:
    if user_collection is None:
        user_collection = db.collection("users")
    doc = await user_collection.document(user_id).get()
    return doc.exists
