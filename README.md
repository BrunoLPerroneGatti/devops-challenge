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
|GET|`/info`|Returns the hostname and EC2 instance ID, allows instances to be identified when running behind a load balancer.|

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
- Docker
- GitHub Container Registry
- Docker Compose
- Nginx
- Application load balancer (ALB)
- Auto scaling groups (ASG)
- Amazon Route 53
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
## Manual deployment

The application is deployed to an AWS EC2 instance using **Ansible** and **Docker Compose**, automating the following tasks:

1. Updates the operating system packages.
2. Install Docker Engine and Docker Compose.
3. Enables and starts the Docker service.
4. Deploys the Docker Compose and Nginx configuration files
5. Start or update the application using Docker Compose.

Once the server is fully configured, an Amazon machine image (AMI) is created from it. This AMI is then used as the base image for additional EC2 instances, ensuring that each instance starts with the same application and Docker configuration.

The resulting infrastructure consists of:
- **Application load balancer (ALB)**: provides a single public entry point and distributes HTTP requests across the available EC2 instances.
- **Auto Scaling Group (ASG)**: manages the number of EC2 instances running the application.
- **EC2 instances**: run the Docker Compose stack.
- **Docker Compose**: runs the FastAPI application and Nginx reverse proxy on each instance.
- **Nginx**:  receives HTTP traffic from the load balancer and forwards it to the FastAPI application.
- **FastAPI**: provides the REST API.

---
## Continuous integration and deployment

The repository uses GitHub actions for both continuous integration and deployment.

The CI workflow automatically runs the project's test suite whenever code is pushed in any branch except `main` or a pull request targeting the `main` branch is created or updated.

Current pipeline:
- Checks out the repository.
- Sets up the Python environment.
- Installs the project dependencies.
- Executes the automated test using Pytest.

The CD workflow is triggered when changes are pushed to the `main` branch and performs the following stages:

- Runs the automated test suite.
- Builds the Docker image.
- Pushes the image to GitHub container registry.
- Deploys the updated application to the EC2 instance using Ansible.