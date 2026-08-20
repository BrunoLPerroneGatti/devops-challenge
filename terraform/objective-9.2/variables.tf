variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "devops-challenge"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "my_ip_cidr" {
  description = "Public IPv4 address allowed to SSH into the server, in CIDR notation"
  type        = string
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}