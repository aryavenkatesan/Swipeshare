import os

from dotenv import load_dotenv

load_dotenv()

def get_env_var(name: str) -> str:
    value = os.getenv(name)
    if value is None:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value

REFRESH_TOKEN_SECRET_KEY = get_env_var("REFRESH_TOKEN_SECRET_KEY")
ACCESS_TOKEN_SECRET_KEY = get_env_var("ACCESS_TOKEN_SECRET_KEY")
JWT_ALGORITHM = get_env_var("JWT_ALGORITHM")

ACCESS_TOKEN_EXPIRE_MINUTES = int(get_env_var("ACCESS_TOKEN_EXPIRE_MINUTES"))
REFRESH_TOKEN_EXPIRE_DAYS = int(get_env_var("REFRESH_TOKEN_EXPIRE_DAYS"))
