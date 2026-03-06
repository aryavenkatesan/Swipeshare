#!/usr/bin/env python3
"""
Script to post 6 test listings to Swipeshare as eunjilee@unc.edu.
Uses Firebase REST API — no SDK needed, just: pip install requests

USAGE:
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python scripts/post_listings.py

"""

import requests
import re
from pathlib import Path
from datetime import datetime, timedelta, timezone

# ── Firebase config (loaded from firebase_options.dart) ───────────────────────
FIREBASE_OPTIONS_PATH = (
    Path(__file__).resolve().parents[1] / "swipeshare_app" / "lib" / "firebase_options.dart"
)


def load_firebase_config(path: Path) -> tuple[str, str]:
    """Returns (api_key, project_id) parsed from Flutter firebase_options.dart."""
    content = path.read_text(encoding="utf-8")

    # Prefer iOS config since this script previously used the iOS API key.
    ios_block_match = re.search(
        r"static\s+const\s+FirebaseOptions\s+ios\s*=\s*FirebaseOptions\((.*?)\);",
        content,
        flags=re.DOTALL,
    )
    if ios_block_match:
        ios_block = ios_block_match.group(1)
        api_key_match = re.search(r"apiKey:\s*'([^']+)'", ios_block)
        project_id_match = re.search(r"projectId:\s*'([^']+)'", ios_block)
        if api_key_match and project_id_match:
            return api_key_match.group(1), project_id_match.group(1)

    # Fallback to first matches in file (works when only one platform is configured).
    api_key_match = re.search(r"apiKey:\s*'([^']+)'", content)
    project_id_match = re.search(r"projectId:\s*'([^']+)'", content)
    if not api_key_match or not project_id_match:
        raise ValueError(f"Could not parse apiKey/projectId from {path}")

    return api_key_match.group(1), project_id_match.group(1)


API_KEY, PROJECT_ID = load_firebase_config(FIREBASE_OPTIONS_PATH)

EMAIL = "eunjilee@unc.edu"
PASSWORD = "password"

# ── Listing data ───────────────────────────────────────────────────────────────
# timeStart / timeEnd are stored as total minutes from midnight
# e.g. 11:30 AM = 11*60+30 = 690

LISTINGS = [
    # ── daysFromNow = 1 (4 listings) ──────────────────────────────────────────
    {
        "diningHall": "Lenoir",
        "timeStart": 690,   # 11:30 AM
        "timeEnd": 750,     # 12:30 PM
        "paymentTypes": ["Venmo", "Cash"],
        "daysFromNow": 1,
    },
    {
        "diningHall": "Chase",
        "timeStart": 1020,  # 5:00 PM
        "timeEnd": 1080,    # 6:00 PM
        "paymentTypes": ["Apple Pay", "Zelle"],
        "daysFromNow": 1,
    },
    {
        "diningHall": "Lenoir",
        "timeStart": 780,   # 1:00 PM
        "timeEnd": 840,     # 2:00 PM
        "paymentTypes": ["Cash", "CashApp"],
        "daysFromNow": 1,
    },
    {
        "diningHall": "Chase",
        "timeStart": 480,   # 8:00 AM
        "timeEnd": 540,     # 9:00 AM
        "paymentTypes": ["Venmo", "PayPal"],
        "daysFromNow": 1,
    },
    # ── daysFromNow = 2 (1 listing) ───────────────────────────────────────────
    {
        "diningHall": "Lenoir",
        "timeStart": 900,   # 3:00 PM
        "timeEnd": 960,     # 4:00 PM
        "paymentTypes": ["Cash", "Venmo"],
        "daysFromNow": 2,
    },
    # ── daysFromNow = 5 (1 listing) ───────────────────────────────────────────
    {
        "diningHall": "Chase",
        "timeStart": 1140,  # 7:00 PM
        "timeEnd": 1200,    # 8:00 PM
        "paymentTypes": ["Zelle", "Apple Pay"],
        "daysFromNow": 5,
    },
]


def sign_in(email: str, password: str) -> tuple[str, str]:
    """Returns (id_token, uid)."""
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
    resp = requests.post(url, json={
        "email": email,
        "password": password,
        "returnSecureToken": True,
    })
    resp.raise_for_status()
    data = resp.json()
    return data["idToken"], data["localId"]


def get_user_doc(uid: str, id_token: str) -> dict:
    """Fetch the Firestore user document for the given UID."""
    url = (
        f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}"
        f"/databases/(default)/documents/users/{uid}"
    )
    resp = requests.get(url, headers={"Authorization": f"Bearer {id_token}"})
    resp.raise_for_status()
    return resp.json()

def fs_string(val: str) -> dict:
    return {"stringValue": val}

def fs_double(val: float) -> dict:
    return {"doubleValue": val}

def fs_int(val: int) -> dict:
    return {"integerValue": str(val)}

def fs_timestamp(dt: datetime) -> dict:
    # Firestore expects RFC3339 UTC
    return {"timestampValue": dt.strftime("%Y-%m-%dT%H:%M:%SZ")}

def fs_array(values: list) -> dict:
    return {"arrayValue": {"values": values}}

def fs_null() -> dict:
    return {"nullValue": None}


def post_listing(listing_data: dict, uid: str, seller_name: str,
                 seller_rating: float, id_token: str) -> str:
    """POSTs a new listing document and returns the created document name."""
    now = datetime.now(timezone.utc)
    transaction_date = now + timedelta(days=listing_data["daysFromNow"])
    # Zero out time component (date only), matching app logic
    transaction_date = transaction_date.replace(hour=0, minute=0, second=0, microsecond=0)

    fields = {
        "sellerId":        fs_string(uid),
        "sellerName":      fs_string(seller_name),
        "diningHall":      fs_string(listing_data["diningHall"]),
        "timeStart":       fs_int(listing_data["timeStart"]),
        "timeEnd":         fs_int(listing_data["timeEnd"]),
        "transactionDate": fs_timestamp(transaction_date),
        "sellerRating":    fs_double(seller_rating),
        "paymentTypes":    fs_array([fs_string(p) for p in listing_data["paymentTypes"]]),
        "price":           fs_null(),
        "status":          fs_string("active"),
    }

    url = (
        f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}"
        f"/databases/(default)/documents/listings"
    )
    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {id_token}"},
        json={"fields": fields},
    )
    resp.raise_for_status()
    return resp.json()["name"]


def main():
    print(f"Signing in as {EMAIL}...")
    id_token, uid = sign_in(EMAIL, PASSWORD)
    print(f"  ✓ Signed in (uid={uid})")

    print("Fetching user profile...")
    user_doc = get_user_doc(uid, id_token)
    user_fields = user_doc["fields"]
    seller_name = user_fields.get("name", {}).get("stringValue", "Unknown")
    seller_rating = float(user_fields.get("stars", {}).get("doubleValue", 5.0))
    print(f"  ✓ Name: {seller_name}, Rating: {seller_rating}")

    print("\nPosting listings...")
    for i, listing in enumerate(LISTINGS, 1):
        doc_name = post_listing(listing, uid, seller_name, seller_rating, id_token)
        doc_id = doc_name.split("/")[-1]
        days_label = f"+{listing['daysFromNow']}d"
        start_h, start_m = divmod(listing["timeStart"], 60)
        end_h, end_m = divmod(listing["timeEnd"], 60)
        print(
            f"  ✓ Listing {i}: {listing['diningHall']} | "
            f"{start_h}:{start_m:02d}–{end_h}:{end_m:02d} | "
            f"{days_label} | id={doc_id}"
        )

    print("\nDone! 6 listings posted.")


if __name__ == "__main__":
    main()
