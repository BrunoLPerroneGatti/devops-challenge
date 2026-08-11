import os
import socket
import httpx

from fastapi import FastAPI

app = FastAPI()

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
    message = os.getenv("APP_MESSAGE", "Hello world")
    return {"message": message}

@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/info")
def get_info():
    hostname = socket.gethostname()
    instance_id = get_instance_id()
    return {"hostname": hostname, "instance_id": instance_id}
