The goal of this challenge was to containerize the application, publish its image to a container registry, and automate the deployment using Docker Compose.

Instead of running the application directly on the EC2 instance through systemd, the server now runs a Docker Compose stack consisting of the application and a reverse proxy.

---
# Containerized Application

The application is packaged into a Docker image using the following approach:

- Based on the official `python:3.14.6-slim` image.
- Installs the application dependencies from `requirements.txt`.
- Copies the application source code.
- Runs the application as a non-root user.
- Starts the application with Uvicorn on port `8080`.

The image is published to **GitHub Container Registry**, allowing the deployment server to pull images instead of building them locally.

---
# Docker Compose

The deployment now consists of two containers:
- `app` : Runs the FastAPI application
- `nginx` : Reverse proxy that exposes the application on port 80

The containers communicate through Docker's internal network, so the application is not directly exposed to the internet.

The application container includes:
- A configurable greeting message through the `APP_MESSAGE` environment variable.
- Automatic restart (`unless-stopped`).
- A health check that periodically calls the `/health` endpoint.

Nginx receives incoming HTTP requests on port 80 and forwards them to the application container.

---
# Ansible Deployment

The previous Ansible playbook was updated to deploy the Docker Compose stack instead of managing a Python virtual environment and a systemd service.

The playbook now performs the following tasks:

1. Updates the operating system packages.
2. Install Docker Engine and Docker Compose.
3. Enables and starts the Docker service.
4. Deploys the Docker Compose and Nginx configuration files
5. Start or update the application using Docker Compose.

Because Ansible is declarative, the deployment remains idempotent and can safely be executed multiple times to apply updates.

---

# How to deploy

From the project root:

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml
```

After the playbook completes, Docker Compose pulls the latest application image from GitHub container registry and starts both containers.

The application is available at:

```
http://INSTANCE-PUBLIC-IP/
```