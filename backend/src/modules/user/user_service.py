from database import db
from google.cloud.firestore import DocumentSnapshot


async def user_exists(user_id: str, user_collection=None) -> bool:
    if user_collection is None:
        user_collection = db.collection("users")
    doc = await user_collection.document(user_id).get()
    return doc.exists


async def get_user_doc_by_email(
    email: str, user_collection=None
) -> DocumentSnapshot | None:
    if user_collection is None:
        user_collection = db.collection("users")
    query = user_collection.where("email", "==", email).limit(1)
    user, *_ = await query.get()
    if user is None or not user.exists:
        return None
    return user
