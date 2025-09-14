import time

from core.config import ACCESS_TOKEN_SECRET_KEY, JWT_ALGORITHM
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from modules.user.user_model import UserDto
from modules.user.user_service import UserService
from core.exceptions import CredentialsException


class HTTPBearer401(HTTPBearer):
    async def __call__(self, request: Request):
        try:
            return await super().__call__(request)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Not authenticated",
                headers={"WWW-Authenticate": "Bearer"},
            )


bearer_scheme = HTTPBearer401()


async def authenticate_user(
    authorization: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    user_service: UserService = Depends(),
) -> UserDto:
    try:
        payload: dict = jwt.decode(
            authorization.credentials,
            ACCESS_TOKEN_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
        )

        email, iat, exp = payload.get("sub"), payload.get("iat"), payload.get("exp")
        if email is None or iat is None or exp is None:
            raise CredentialsException()

        current_time = int(time.time())
        if current_time < iat or current_time > exp:
            raise CredentialsException()

        return await user_service.get_user_by_email(email)
    except JWTError:
        raise CredentialsException()
