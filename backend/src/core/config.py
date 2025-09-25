import os
from typing import Any

from dotenv import load_dotenv

load_dotenv()


def get_env_var(name: str, default: Any = None) -> str:
    value = os.getenv(name) or default
    if value is None:
        raise ValueError(f"Environment variable {name} is not set")
    return value


REFRESH_TOKEN_SECRET_KEY = get_env_var("REFRESH_TOKEN_SECRET_KEY")
ACCESS_TOKEN_SECRET_KEY = get_env_var("ACCESS_TOKEN_SECRET_KEY")
JWT_ALGORITHM = get_env_var("JWT_ALGORITHM", "HS256")

ACCESS_TOKEN_EXPIRE_MINUTES = int(get_env_var("ACCESS_TOKEN_EXPIRE_MINUTES", 15))
REFRESH_TOKEN_EXPIRE_DAYS = int(get_env_var("REFRESH_TOKEN_EXPIRE_DAYS", 7))

CHAT_QUEUE_SIZE = int(get_env_var("CHAT_QUEUE_SIZE", 50))
MESSAGE_STREAM_TIMEOUT_SECONDS = int(get_env_var("MESSAGE_STREAM_TIMEOUT_SECONDS", 30))
