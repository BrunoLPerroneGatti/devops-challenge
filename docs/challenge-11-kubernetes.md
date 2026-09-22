The goal of this challenge was to migrate the application and its supporting services to Kubernetes, integrating the system into the existing workflow with automated deployment, monitoring, logging, and continuous delivery.

Kubernetes is a container orchestration platform that automates the deployment, scaling, networking, and management of containerized applications. It provides a consistent and declarative way to manage applications across environments, reducing the need for manual operational tasks and making application deployments more repeatable and easier to automate.  

The challenge was implemented in two environments:

- **Kind** for local Kubernetes development and testing.    
- **Amazon EKS** for the cloud deployment.    

The project has progressed from manually deploying the application to EC2, through infrastructure and configuration automation with Terraform and Ansible, to a Kubernetes system with integrated observability and automated CI/CD.

---

# Local Kubernetes with Kind

To develop and validate the Kubernetes configuration before using AWS resources, the application was first deployed to a local cluster using Kind.

Kind allows Kubernetes clusters to be created locally using Docker containers, making it possible to test the Kubernetes resources and deployment behavior without incurring cloud resource usage.

The cluster consists of one control plane node and two worker nodes.

The application resources were organized into a dedicated `development` namespace.

A Kubernetes deployment was created with two replicas of the application. This allowed the behavior of multiple application pods to be tested before moving the deployment to AWS.

The application was exposed locally through a NodePort service, allowing requests from the host machine to reach the application running inside the Kind cluster.

## Observability with Helm

After the application was running on Kubernetes, the existing observability stack from challenge 10 was migrated to the cluster.

Instead of manually creating each observability component, Helm was used to install the `kube-prometheus-stack` chart.

The stack provides:

- Prometheus    
- Grafana    
- Alertmanager    
- kube-state-metrics    
- node-exporter    

The existing application monitoring configuration was also adapted to Kubernetes.

A `ServiceMonitor` was created so that Prometheus could discover the application service and scrape its `/metrics` endpoint.

The Grafana dashboard from Challenge 10 was also reused. It was stored as a Kubernetes ConfigMap and automatically loaded into Grafana using the dashboard sidecar.

The existing Prometheus alerting rule was converted into a Kubernetes `PrometheusRule`, allowing Prometheus to continue monitoring the application's HTTP request rate and send alerts to Alertmanager.

At this point, the application and its monitoring stack were running entirely inside the local Kubernetes cluster.

---

# Deployment to Amazon EKS

After validating the Kubernetes deployment locally, the application was migrated to Amazon EKS.

The EKS cluster was created using `eksctl` with a managed node group containing two `t3.small` worker nodes.

The cluster has OIDC enabled, which is later used by GitHub actions for authentication.

The deployment continues to run two replicas of the application. The main difference is how the application is exposed.
Instead of the local NodePort service, the EKS deployment uses a LoadBalancer service. The AWS Load Balancer controller was installed in the cluster and configured to manage AWS load balancers for Kubernetes services.
The Service creates an internet facing **Network Load Balancer (NLB)**, providing a public entry point to the application.

The `/info` endpoint was particularly useful for verifying the Kubernetes deployment because it exposes the hostname of the pod handling the request. Multiple requests could therefore be used to observe traffic reaching the different application replicas.

## Logging with Loki and Alloy

The monitoring configuration from Challenge 10 was reused in EKS, but the logging implementation required changes because the application was no longer running inside Docker Compose.

For the EKS deployment, Loki and Grafana Alloy were added to the observability stack.

The application itself still writes logs to standard output through Uvicorn, so no application changes were required. The difference is how those logs are collected.
In Challenge 10, Alloy discovered and collected logs from Docker containers through the Docker API.
In Kubernetes, Alloy runs as a DaemonSet and uses Kubernetes service discovery to discover pods and collect their container logs.

The Alloy configuration also extracts Kubernetes metadata such as:

- Namespace    
- Pod    
- Container    
- Application    
- Node    

These values are added as labels and can then be used to filter the logs in Grafana.

For example:

```text
{namespace="development", app="devops-challenge-app"}
```

Loki was configured as a lightweight deployment suitable for the scope of this project rather than as a highly available production logging system.

The existing Grafana instance was also configured with Loki as a data source, allowing both metrics and Kubernetes logs to be inspected through Grafana.

---

# CI/CD with Kubernetes

Once the complete application and observability stack was running on EKS, the final step was to integrate the Kubernetes deployment into the existing GitHub actions CD pipeline.

The pipeline continues to use the CI workflow from the previous challenges before building the application image.

## Docker image tagging

The Docker build step was modified to publish two tags to GitHub Container Registry:

- latest
- the Git commit SHA    

The commit SHA provides a unique reference to the image created by a particular commit.

This is important for the Kubernetes deployment because the pipeline can update the deployment to use the exact image generated by the commit that triggered the workflow instead of relying on the mutable latest tag.

The resulting image reference has the following form:

```text
ghcr.io/brunolperronegatti/devops-challenge:<commit-sha>
```

## GitHub actions access to AWS

The deployment job needs to authenticate with AWS before it can communicate with the EKS cluster.

Instead of storing permanent AWS access keys as GitHub actions secrets, **GitHub Actions OIDC** was configured.

A dedicated IAM role was created for the GitHub Actions workflow.

The role's trust policy restricts which GitHub repository and branch can assume it, and GitHub actions requests temporary AWS credentials.
The workflow therefore only needs the permission to request an AWS role session.

## EKS access

Authenticating with AWS does not automatically grant the GitHub actions role permission to interact with the Kubernetes API.

Therefore, the IAM role was also added to the EKS cluster through an **EKS access entry**.

The role was associated with the `AmazonEKSEditPolicy`, scoped specifically to the `development` namespace.

This allows the CI/CD pipeline to modify the application resources it needs without granting the GitHub actions role unrestricted access to the entire cluster.

After authentication, the workflow uses the AWS CLI to configure the Kubernetes context.
The pipeline can then use `kubectl` to interact with the cluster.

## Automated Kubernetes deployment

Once the Docker image has been published and the Kubernetes API is accessible, the deployment job updates the running application.

The image of the existing Deployment is changed to the image tagged with the current Git commit SHA.
Kubernetes then performs the deployment update and creates new pods using the new image.

The workflow finishes by waiting for the rollout to complete.
This ensures that the GitHub actions workflow does not finish successfully simply because the deployment update was submitted. The workflow also waits for Kubernetes to complete the rollout.