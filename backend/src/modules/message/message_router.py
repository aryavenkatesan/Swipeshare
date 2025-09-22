import asyncio
import json
from datetime import datetime

from core.authentication import authenticate_user
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import StreamingResponse
from core.config import MESSAGE_STREAM_TIMEOUT_SECONDS
from modules.message.message_model import MessageCreate, MessageDto
from modules.message.message_service import MessageService
from modules.order.order_service import OrderService
from modules.user.user_model import UserDto

message_router = APIRouter(tags=["Messages"])


@message_router.get("/orders/{order_id}/messages/message-stream")
async def sse_message_stream(
    request: Request,
    order_id: str,
    message_service: MessageService = Depends(),
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> StreamingResponse:
    order = await order_service.get_order_by_id(order_id)
    if order.buyer_id != user.id and order.seller_id != user.id:
        raise HTTPException(403, "You are not allowed to access this chat room")

    async def message_stream_generator():
        message_queue = None
        try:
            message_queue = await message_service.get_message_queue(order_id)
            while True:
                if await request.is_disconnected():
                    break

                try:
                    message = await asyncio.wait_for(
                        message_queue.get(),
                        timeout=MESSAGE_STREAM_TIMEOUT_SECONDS,
                    )
                    message_envelope = {"type": "message", "data": message.model_dump_json()}
                    yield f"data: {json.dumps(message_envelope)}\n\n"

                except TimeoutError:
                    heartbeat_envelope = {
                        "type": "heartbeat",
                        "data": {"timestamp": datetime.now().isoformat()},
                    }
                    yield f"data: {json.dumps(heartbeat_envelope)}\n\n"

        except Exception as e:
            error_envelope = {
                "type": "error",
                "data": {
                    "message": f"Stream terminated: [{type(e).__name__}] {str(e)}",
                    "error_type": type(e).__name__,
                },
            }
            yield f"data: {json.dumps(error_envelope)}\n\n"
        finally:
            await message_service.cleanup_message_queue(order_id)

    return StreamingResponse(
        message_stream_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@message_router.post(
    "/orders/{order_id}/messages", response_model=MessageDto, status_code=201
)
async def post_message(
    order_id: str,
    message_data: MessageCreate,
    message_service: MessageService = Depends(),
    order_service: OrderService = Depends(),
    user: UserDto = Depends(authenticate_user),
) -> MessageDto:
    order = await order_service.get_order_by_id(order_id)
    if order.buyer_id != user.id and order.seller_id != user.id:
        raise HTTPException(403, "You are not allowed to send messages to this order")

    return await message_service.add_message_to_order(message_data, order_id, user)
