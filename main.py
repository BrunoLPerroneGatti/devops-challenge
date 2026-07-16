import os
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def hello():
    message = os.getenv("APP_MESSAGE", "Hello world")
    return {"message": message}

@app.get("/health")
def health():
    return {"status": "ok"}
