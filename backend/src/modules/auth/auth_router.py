import time
from typing import Literal, Optional

from core.config import JWT_ALGORITHM, REFRESH_TOKEN_SECRET_KEY
from fastapi import APIRouter, Cookie, Depends, HTTPException, Response
from jose import JWTError, jwt
from modules.auth.auth_model import (
    AccessTokenDto,
    LoginData,
    MoblieAuthDto,
    RefreshData,
    WebAuthDto,
)
from modules.auth.auth_service import (
    create_access_token,
    create_refresh_token,
    verify_password,
)
from modules.user.user_model import UserCreate, UserDto
from modules.user.user_service import UserService
from core.exceptions import CredentialsException, NotFoundException
from core.get_platform import get_platform

auth_router = APIRouter(prefix="/api/auth")


@auth_router.post(
    "/signup",
    status_code=201,
    response_model=WebAuthDto | MoblieAuthDto,
    description="Sign up a new user. Refresh token will be returned in cookies if platform = `web`",
)
async def signup(
    response: Response,
    data: LoginData,
    user_service: UserService = Depends(),
    platform: Literal["web", "mobile"] = Depends(get_platform),
) -> WebAuthDto | MoblieAuthDto:
    user_create_data = UserCreate(email=data.email, password=data.password)
    user = await user_service.create_user(user_create_data)
    return _get_auth_response(user, platform, response)


@auth_router.post(
    "/login",
    response_model=WebAuthDto | MoblieAuthDto,
    description="Log in an existing user. Refresh token will be returned in cookies if platform = `web`",
)
async def login(
    response: Response,
    data: LoginData,
    platform: Literal["web", "mobile"] = Depends(get_platform),
    user_service: UserService = Depends(),
) -> WebAuthDto | MoblieAuthDto:
    try:
        db_password = await user_service.get_hashed_password(data.email)
    except NotFoundException:
        raise CredentialsException()

    if not verify_password(data.password, db_password):
        raise CredentialsException()

    user = await user_service.get_user_by_email(data.email)
    return _get_auth_response(user, platform, response)


def _get_auth_response(
    user: UserDto, platform: str, response: Response
) -> WebAuthDto | MoblieAuthDto:
    access_token = create_access_token(data={"sub": user.email})
    refresh_token = create_refresh_token(data={"sub": user.email})

    if platform == "web":
        response.set_cookie(
            key="refresh_token",
            value=refresh_token,
            httponly=True,
            secure=True,
            samesite="strict",
        )
        return WebAuthDto(
            user=user,
            access_token=access_token,
        )
    else:
        return MoblieAuthDto(
            user=user,
            access_token=access_token,
            refresh_token=refresh_token,
        )


@auth_router.post(
    "/refresh",
    response_model=AccessTokenDto,
    description="Refresh access token using refresh token. For `web` platform, the refresh token should be provided in `refresh_token` cookie. For `mobile` platform, the refresh token should be provided in the request body.",
)
async def refresh_access_token(
    data: RefreshData,
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

    try:
        payload = jwt.decode(
            token, REFRESH_TOKEN_SECRET_KEY, algorithms=[JWT_ALGORITHM]
        )
    except JWTError:
        raise CredentialsException()

    # token payload should be correctly formed
    email, iat, exp = payload.get("sub"), payload.get("iat"), payload.get("exp")
    if email is None or iat is None or exp is None:
        raise CredentialsException()

    # token should not be expired
    current_time = int(time.time())
    if current_time < iat or current_time > exp:
        raise CredentialsException()

    new_access_token = create_access_token(data={"sub": email})
    return AccessTokenDto(access_token=new_access_token)
