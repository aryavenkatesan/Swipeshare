import json

import requests

print("Starting SSE client...")

response = requests.get(
    "http://localhost:8000/orders/NAoBSXVdMYEmFj8JuNHO/messages/message-stream",
    headers={
        "Accept": "text/event-stream",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiQGMuY29tIiwiaWF0IjoxNzU4NTcwMDUyLCJleHAiOjE3NTg1NzA5NTJ9.W_aJ3ohWgjX_XxkmDH9P5FxpLiL95x7fAn8UbnHTlG4",
    },
    stream=True,
    timeout=(10, 120),  # 10s connection timeout, 120s read timeout
)

print("Response status code:", response.status_code)

for line in response.iter_lines():
    if line:
        decoded_line = line.decode("utf-8")
        if decoded_line.startswith("data: "):
            data = decoded_line[6:]  # Remove 'data: ' prefix
            message = json.loads(data)
            print("Received message:", message)
