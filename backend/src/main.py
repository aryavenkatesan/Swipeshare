from contextlib import asynccontextmanager

from database import check_firestore_connection
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from modules.auth.auth_router import auth_router
from modules.listing.listing_router import listing_router
from modules.order.order_router import order_router
from modules.user.user_router import user_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await check_firestore_connection()
    yield


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:61433",  # Flutter web dev server alternative port
    ],
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)


@app.exception_handler(HTTPException)
def handle_http_exception(req: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"message": exc.detail},
    )


@app.exception_handler(Exception)
def handle_general_exception(req: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"message": "An unexpected error occurred.", "detail": str(exc)},
    )


@app.get("/api")
def read_root():
    return {"message": "Successful Test"}


app.include_router(auth_router, tags=["Auth"])
app.include_router(user_router, tags=["Users"])
app.include_router(order_router, tags=["Orders"])
app.include_router(listing_router, tags=["Listings"])
