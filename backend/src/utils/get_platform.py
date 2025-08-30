from typing import Literal

from fastapi import Header, HTTPException


def get_platform(
    x_client_type: Literal["web", "mobile"] = Header(None),
) -> Literal["web", "mobile"]:
    if x_client_type in ("web", "mobile"):
        return x_client_type
    else:
        raise HTTPException(
            status_code=400,
            detail="X-Client-Type header is missing or invalid. Enter 'web' or 'mobile'.",
        )
