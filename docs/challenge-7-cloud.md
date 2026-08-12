The goal of this challenge was to extend the application deployment to support multiple AWS EC2 instances behind a load balancer and automatically scale the number of instances based on demand.

---
## Application Changes

The `/info` endpoint was updated to return both the hostname and the EC2 instance ID.
This makes it possible to identify which EC2 instance handled each request when multiple instances are running behind a load balancer.

New endpoint behavior:
```json
{
  "hostname": "ip-10-0-1-101",
  "instance_id": "i-0a1b2c3d4e5f67890"
}
```

The instance ID is obtained through the **EC2 IMDS** (instance metadata service). The application first requests an IMDSv2 session token and then uses that token to retrieve the instance ID.

If the metadata service cannot be reached, the endpoint returns `"unavailable"` instead of causing the request to fail.

---
# AMI

The next step was to create an **Amazon machine image (AMI)** containing the already configured application server.

First, an EC2 instance was created and the application was deployed using the Ansible configuration from Challenge 6.

The resulting instance contained the complete Docker deployment, including:
- Docker Engine    
- Docker Compose    
- Application configuration    
- Nginx configuration    
- Docker Compose configuration    
- The application deployment    

An AMI was then created from this configured instance.

The AMI provides a reusable image of the server state, allowing additional EC2 instances to be created with the same configuration without manually repeating the entire setup process.

Two new EC2 instances were created using the custom AMI, both instances starting with the same application and infrastructure configuration.

---
# Application load balancer

An **application load balancer (ALB)** was configured to distribute incoming HTTP requests between the EC2 instances.

A target group was created containing the two EC2 instances, and the ALB was configured to forward HTTP traffic to the target group.

The ALB provides a single entry point for the application while distributing requests across the available instances.

The `/info` endpoint can be used to verify the behavior by making multiple requests and observing different instance IDs.

---
# Auto scaling group

After testing the load balancer with manually created instances, the instances were terminated and an **auto scaling group (ASG)** was created, attached to the ALB target group created earlier.

The custom AMI was used as the basis for instances launched by the auto scaling group.

The ASG is responsible for maintaining the desired number of application instances and can automatically launch or terminate instances according to its scaling configuration.

Multiple instances can run the same application, while the load balancer provides a single entry point and the auto scaling group manages application capacity.

---
## DNS - Route 53

**Amazon Route 53** can be used to associate a domain name with the application's load balancer instead of accessing it through the AWS generated DNS name.

For example:

```text
example.com
     │
     ▼
Application Load Balancer
     │
     ▼
EC2 instances
```

I did not configure Route 53 for this project because doing so would require using a registered domain and potentially incur additional costs. 
