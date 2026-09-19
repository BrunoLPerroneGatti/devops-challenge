import os
import socket
import httpx

from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

Instrumentator(
    excluded_handlers=["/metrics"]
).instrument(app).expose(app)

def get_instance_id() -> str:
    try:
        token_response = httpx.put(
            "http://169.254.169.254/latest/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
            timeout=2.0,
        )
        token = token_response.text
        id_response = httpx.get(
            "http://169.254.169.254/latest/meta-data/instance-id",
            headers={"X-aws-ec2-metadata-token": token},
            timeout=2.0,
        )
        return id_response.text
    except Exception:
        return "unavailable"     


@app.get("/")
def hello():
    message = os.getenv("APP_MESSAGE", "Hello world 0.11")
    return {"message": message}

@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/info")
def get_info():
    hostname = socket.gethostname()
    instance_id = get_instance_id()
    return {"hostname": hostname, "instance_id": instance_id}

@app.get("/error")
def error():
    raise RuntimeError("Something went wrong")

