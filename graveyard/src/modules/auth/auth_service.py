from datetime import datetime, timedelta, timezone

from core.config import (
    ACCESS_TOKEN_EXPIRE_MINUTES,
    ACCESS_TOKEN_SECRET_KEY,
    JWT_ALGORITHM,
    REFRESH_TOKEN_EXPIRE_DAYS,
    REFRESH_TOKEN_SECRET_KEY,
)
from jose import jwt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict):
    to_encode = data.copy()
    to_encode["iat"] = datetime.now(timezone.utc)
    to_encode["exp"] = to_encode["iat"] + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    return jwt.encode(to_encode, ACCESS_TOKEN_SECRET_KEY, algorithm=JWT_ALGORITHM)


def create_refresh_token(data: dict):
    to_encode = data.copy()
    to_encode["iat"] = datetime.now(timezone.utc)
    to_encode["exp"] = to_encode["iat"] + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    return jwt.encode(to_encode, REFRESH_TOKEN_SECRET_KEY, algorithm=JWT_ALGORITHM)
