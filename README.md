# DevOps Upskill Challenge

A hands-on DevOps learning portfolio documenting my progress through the [DevOps Upskill Challenge](https://devopsupskillchallenge.com): from "Hello World" to Kubernetes. 
This roadmap covers Linux, HTTP, Git, Cloud, Docker, infrastructure as code, CI/CD, observability  & alerting, and Kubernetes.

Each challenge builds on the previous one using the same application, progressively adding new features and infrastructure on top of the previous one.

Documentation for every completed challenge is available in the `/docs` directory.

---
## Current Application

At this stage, the project consists of a small REST API built with Python using **FastAPI**.

Available endpoints:

|Method|Endpoint|Description|
|---|---|---|
|GET|`/`|Returns a JSON message (`Hello world` by default).|
|GET|`/health`|Returns the application's health status.|
|GET|`/info`|Returns the hostname.|

The greeting message is configurable via the `APP_MESSAGE` environment variable.

Example response:

```json
{
  "message": "Hello world"
}
```

Health endpoint:

```json
{
  "status": "ok"
}
```

## Technologies Used

- Python    
- FastAPI    
- Uvicorn    
- Pytest  
- httpx
- Github actions
- AWS EC2 
- systemd
- Ansible
---
## Running locally

```bash
# Clone the repository
git clone https://github.com/BrunoLPerroneGatti/devops-challenge.git
cd devops-challenge

# Create a virtual environment and run it (recommended):
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8080 
```

The API will be available at `http://localhost:8080`.

---
## Continuous Integration

The repository includes a GitHub Actions workflow that automatically runs the project's test suite whenever code is pushed or a pull request targeting the `main` branch is created or updated.

Current pipeline:
- Checks out the repository.
- Sets up the Python environment.
- Installs the project dependencies.
- Executes the automated test using Pytest.

---
## Deployment

The application is deployed to an AWS EC2 instance using **Ansible**, automating the following tasks:

1. Update the package index and upgrade installed packages.
2. Install the required system dependencies.
3. Clone or update the application repository.
4. Create a Python virtual environment and install the application dependencies.
5. Generate the systemd service.
6. Reload systemd and restarts the application service.