The goal of this challenge was to build a simple application capable of responding to HTTP requests with "Hello World", while learning the core concepts behind HTTP, REST APIs, and web architecture.

---
# The Application

A small REST API with the available endpoints:

|Method|Endpoint|Description|
|---|---|---|
|GET|`/`|Returns a JSON message (`Hello world` by default).|
|GET|`/health`|Returns the application's health status.|

The `/health` endpoint is commonly used by monitoring systems, load balancers, and orchestration platforms (such as Kubernetes) to verify that the application is running correctly.

The application also supports configuring the greeting message through the `APP_MESSAGE` environment variable. This allows the application's behavior to be configured without changing the source code.
## Technologies Used

| Technology | Purpose |
|------------|---------|
| Python | Programming language used to implement the application |
| FastAPI | Web framework used to build the REST API |
| Uvicorn | ASGI server used to run the application |
| Pytest | Framework for automated testing |
| httpx | HTTP client used by FastAPI's `TestClient` during testing |

## Testing
The project includes automated tests written with **Pytest** and FastAPI's `TestClient`. They will be helpful in verifying that the APP behaves as expected before any deployment.

Current tests verify that:
- The root endpoint returns HTTP 200.    
- The response contains the expected JSON structure.    
- The health endpoint returns HTTP 200.    
- The health endpoint returns `{"status": "ok"}`.    

---

## How to run

```bash
# Create a virtual environment and run it (recommended):
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8080

# Test endpoints manually
http://localhost:8080/
http://localhost:8080/health

# With custom message
# Linux
APP_MESSAGE="Hello devops-challenge" uvicorn main:app --host 0.0.0.0 --port 8080 

# Windows (Powershell)
$env:APP_MESSAGE="Hello devops-challenge"; uvicorn main:app --host 0.0.0.0 --port 8080

# Run tests
pytest tests/ -v

# Interactive API documentation is available at:
http://localhost:8080/docs
```


