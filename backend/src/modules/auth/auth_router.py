import time
from typing import Literal, Optional

from core.config import JWT_ALGORITHM, REFRESH_TOKEN_SECRET_KEY
from fastapi import APIRouter, Cookie, Depends, HTTPException, Response
from google.cloud.firestore_v1.async_collection import AsyncCollectionReference
from jose import JWTError, jwt
from modules.auth.auth_model import (
    AccessTokenDto,
    CreateTokenDto,
    RefreshTokenDto,
    TokensDto,
)
from modules.auth.auth_service import (
    create_access_token,
    create_refresh_token,
    verify_password,
)
from modules.user.user_service import get_user_doc_by_email
from utils.collections import get_user_collection
from utils.get_platform import get_platform

auth_router = APIRouter(prefix="/api/auth")


@auth_router.post("/token", response_model=TokensDto | AccessTokenDto)
async def create_token(
    response: Response,
    data: CreateTokenDto,
    platform: Literal["web", "mobile"] = Depends(get_platform),
    user_collection: AsyncCollectionReference = Depends(get_user_collection),
) -> TokensDto | AccessTokenDto:
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    user = await get_user_doc_by_email(data.email, user_collection)
    if not user or not (user_data := user.to_dict()):
        raise credentials_exception
    db_password = user_data.get("password")
    if db_password is None or not verify_password(data.password, db_password):
        raise credentials_exception

    access_token = create_access_token(data={"sub": data.email})
    refresh_token = create_refresh_token(data={"sub": data.email})

    if platform == "mobile":
        return TokensDto(
            access_token=access_token,
            refresh_token=refresh_token,
        )
    else:
        response.set_cookie(
            key="refresh_token",
            value=refresh_token,
            httponly=True,
            secure=True,
            samesite="strict",
        )
        return AccessTokenDto(
            access_token=access_token,
        )


@auth_router.post("/refresh")
async def refresh_token(
    data: RefreshTokenDto,
    refresh_token: Optional[str] = Cookie(None),
    platform: Literal["web", "mobile"] = Depends(get_platform),
) -> AccessTokenDto:
    if platform == "mobile":
        if data.refresh_token is None:
            raise HTTPException(
                400, "Refresh token is required in body for mobile platform"
            )
        token = data.refresh_token
    elif platform == "web":
        if refresh_token is None:
            raise HTTPException(
                400,
                "Refresh token is required in `refresh_token` cookie for web platform",
            )
        token = refresh_token

    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(
            token, REFRESH_TOKEN_SECRET_KEY, algorithms=[JWT_ALGORITHM]
        )
    except JWTError:
        raise credentials_exception

    email, iat, exp = payload.get("sub"), payload.get("iat"), payload.get("exp")
    if email is None or iat is None or exp is None:
        raise credentials_exception

    current_time = int(time.time())
    if current_time < iat or current_time > exp:
        raise credentials_exception

    new_access_token = create_access_token(data={"sub": email})
    return AccessTokenDto(access_token=new_access_token)
