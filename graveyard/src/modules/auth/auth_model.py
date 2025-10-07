from typing import Optional

from modules.user.user_model import UserDto
from pydantic import BaseModel, EmailStr


class LoginData(BaseModel):
    email: EmailStr
    password: str


class WebAuthDto(BaseModel):
    user: UserDto
    access_token: str


class MoblieAuthDto(BaseModel):
    user: UserDto
    access_token: str
    refresh_token: str


class RefreshData(BaseModel):
    refresh_token: Optional[str] = None


class AccessTokenDto(BaseModel):
    access_token: str
