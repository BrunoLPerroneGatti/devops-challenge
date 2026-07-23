from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_hello_returns_message():
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_info_returns_expected_fields():
    response = client.get("/info")
    assert response.status_code == 200
    assert "hostname" in response.json()
