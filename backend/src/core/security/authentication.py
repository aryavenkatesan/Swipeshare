import time

from core.config import ACCESS_TOKEN_SECRET_KEY, JWT_ALGORITHM
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from jose import JWTError, jwt
from modules.user.user_model import UserDto
from modules.user.user_service import get_user_doc_by_email
from utils.collections import get_user_collection

bearer_scheme = HTTPBearer()


async def authenticate_user(
    authorization: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> UserDto:
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload: dict = jwt.decode(
            authorization.credentials,
            ACCESS_TOKEN_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
        )

        email, iat, exp = payload.get("sub"), payload.get("iat"), payload.get("exp")
        if email is None or iat is None or exp is None:
            raise credentials_exception

        current_time = int(time.time())
        if current_time < iat or current_time > exp:
            raise credentials_exception

        user = await get_user_doc_by_email(email, user_collection)
        if not user:
            raise credentials_exception
        return UserDto.from_doc(user)
    except JWTError:
        raise credentials_exception
