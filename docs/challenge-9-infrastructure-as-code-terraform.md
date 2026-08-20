The goal of this challenge was to recreate the AWS infrastructure from the previous challenges using Terraform.

Terraform allows infrastructure to be defined and managed as code, making it possible to reproduce the infrastructure without manually creating each AWS resource.

The challenge was divided into two separate Terraform configurations so that each objective could be tested independently:

- **Objective 9.1** : Create an EC2 instance and its basic requirements.    
- **Objective 9.2**: Recreate the infrastructure from challenge 7.    

The project now uses both Terraform and Ansible, but they have different responsibilities.
Terraform provisions and manages the infrastructure, while Ansible handles server configuration and application deployment.

---

# Objective 9.1 - EC2 instance and requirements

The first part focused on the basic Terraform workflow and creating a single EC2 instance.

Terraform manages the following resources:
- EC2 instance    
- Security group      

The configuration also uses AWS data sources to locate existing infrastructure:
- The default VPC    
- A default subnet    
- The latest matching Ubuntu 24.04 AMI    

For this exercise, Terraform does not create a new VPC or subnet, instead, it reuses the AWS account's existing default VPC and subnet.

SSH access is restricted to the IP address provided through the `my_ip_cidr` Terraform variable, while HTTP access is allowed from the internet.

The EC2 instance type, AWS region, project name, SSH cidr, and key pair are configurable through Terraform variables.

---

# Objective 9.2 - Recreating the Cloud Infrastructure

The second part of the challenge recreated the main AWS infrastructure from challenge 7 using Terraform.

Terraform manages the following resources:
- Application load balancer    
- Target group    
- Load balancer security group    
- EC2 security group    
- Launch template    
- Auto scaling group    
- EC2 instances    

As in 9.1, the configuration uses the existing default VPC and its default subnets rather than creating a new VPC.

### AMI and launch template

The configuration uses the custom AMI created during challenge 7.

That AMI contains the previously configured application server, including the docker based deployment.

Terraform uses the AMI to create an AWS launch template, which defines how new EC2 instances should be configured.

This allows the auto scaling group to launch additional instances with the same application environment.

### Security groups

Two security groups are used in the Terraform configuration.
- ALB Security Group : allows HTTP traffic from the internet and all outbound IPv4 traffic.
- EC2 Security Group : allows SSH from the configured local IP, HTTP from the ALB security group and all outbound IPv4 traffic.    

Importantly, the EC2 instances do not need to accept HTTP traffic directly from the entire internet. HTTP access is restricted to traffic originating from the ALB security group.

---

# Terraform workflow

The standard Terraform workflow is used for both configurations.

```bash
terraform init # Initializes the working directory. Downloads providers/modules.
terraform fmt  # Formats Terraform files.
terraform validate # Checks whether the configuration is syntactically and internally valid.
terraform plan # Shows the changes Terraform intends to make before applying them.
terraform apply # Executes the plan.
terraform destroy # Destroys resources managed by the configuration.
```

Terraform state is used to keep track of the resources managed by each configuration.
