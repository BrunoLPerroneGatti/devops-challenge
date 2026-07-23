import os
import socket
from fastapi import FastAPI

app = FastAPI()

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
    return {"hostname": hostname}
