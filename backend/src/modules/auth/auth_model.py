from typing import Optional

from pydantic import BaseModel, EmailStr


class CreateTokenDto(BaseModel):
    email: EmailStr
    password: str


class RefreshTokenDto(BaseModel):
    refresh_token: Optional[str] = None


class AccessTokenDto(BaseModel):
    access_token: str


class TokensDto(RefreshTokenDto, AccessTokenDto):
    pass
