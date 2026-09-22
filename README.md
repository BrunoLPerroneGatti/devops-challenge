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
|GET|`/info`|Returns the hostname and EC2 instance ID, useful for identifying the instance or pod handling a request.|

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
- Terraform
- Prometheus
- Grafana
- Loki
- Kubernetes

---

## Running locally

```bash
# Clone the repository
git clone https://github.com/BrunoLPerroneGatti/devops-challenge.git
cd devops-challenge/app

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

## Deployment

The project evolved through multiple deployment approaches as new challenges were completed.

### EC2 deployment

The application was deployed on AWS using **Terraform** and **Ansible**.

Terraform is responsible for provisioning and managing the AWS infrastructure, including the EC2 instances, security groups, application load balancer, target group, and auto scaling group.

Ansible is responsible for configuring the EC2 instances and deploying the application using Docker Compose, automating the following tasks:
1. Update the operating system packages.
2. Install Docker Engine and Docker Compose.
3. Enable and starts the Docker service.
4. Deploy the Docker Compose and Nginx configuration files
5. Start or update the application using Docker Compose.
  
Once a server is fully configured, an Amazon machine image (AMI) is created from it. This AMI is then used as the base image for additional EC2 instances, ensuring that each instance starts with the same application and Docker configuration.

The resulting infrastructure consists of:
- **Application load balancer (ALB)**: provides a single public entry point and distributes HTTP requests across the available EC2 instances.
- **Auto Scaling Group (ASG)**: manages the number of EC2 instances running the application.
- **EC2 instances**: run the Docker Compose stack.
- **Docker Compose**: runs the FastAPI application and Nginx reverse proxy on each instance.
- **Nginx**:  receives HTTP traffic from the load balancer and forwards it to the FastAPI application.
- **FastAPI**: provides the REST API.

### Kubernetes deployment

Challenge 11 migrated the application and its supporting services to **Kubernetes**.

A local **Kind** cluster was used for Kubernetes development and testing, while **Amazon EKS** provides the cloud Kubernetes environment.

The application runs as a Kubernetes deployment with two replicas and is exposed through a Kubernetes service. In EKS, the service is integrated with the **AWS Load Balancer Controller**, which creates an internet facing network load balancer (NLB).

The Kubernetes environment also includes an observability stack and automated deployment through GitHub actions.

The project therefore retains the previous EC2-based deployment as part of the progression while providing a Kubernetes-based deployment as the latest stage of the challenge.

---

## Continuous integration and deployment

The repository uses GitHub actions for both continuous integration and deployment.

The CI workflow automatically runs the project's test suite whenever code is pushed to any branch except `main`, or when a pull request targeting the `main` branch is created or updated.

Current pipeline:

- Checks out the repository.
- Sets up the Python environment.
- Installs the project dependencies.
- Executes the automated test using Pytest.

The CD workflow is triggered when changes are pushed to the `main` branch and performs the following stages:

- Runs the automated test suite.
- Builds the Docker image.
- Pushes the image to GitHub container registry.
- Tags the image with both `latest` and the Git commit SHA.
- Authenticates with AWS using GitHub Actions OIDC.
- Updates the application deployment in Amazon EKS to use the image associated with the commit.

## Observability & alerting

The application includes an observability stack based on Prometheus, Grafana, Loki, Grafana Alloy, and Alertmanager.

Prometheus collects HTTP metrics exposed by the FastAPI application, including request counts, request rates, request duration, and HTTP status codes.

Grafana is used to visualize the collected metrics and provides dashboards for monitoring HTTP traffic, request duration, and error rates.

Application logs are collected by Grafana Alloy and sent to Loki. These logs can then be queried and explored through Grafana.

Prometheus alerting rules are used to detect abnormal HTTP request rates. Alertmanager receives and manages alerts generated by Prometheus.

The observability stack was initially deployed using Docker Compose in Challenge 10. In Challenge 11, the same observability approach was adapted to Kubernetes using Helm, with Alloy using Kubernetes service discovery to collect application logs from Pods.