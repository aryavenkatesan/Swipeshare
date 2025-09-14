import os

from google.api_core.exceptions import GoogleAPIError
from google.cloud import firestore

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "serviceAccountKey.json"
db = firestore.AsyncClient()


def get_db():
    return db


async def check_firestore_connection():
    try:
        await db.collection("test").get()
        print("[Firestore] Successfully connected.")
    except GoogleAPIError as e:
        print(f"[Firestore] Credentials are invalid: {e}")
    except Exception as e:
        print(f"[Firestore] Unexpected error: {e}")
