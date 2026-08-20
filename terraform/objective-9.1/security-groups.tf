resource "aws_security_group" "instance" {
  name        = "${var.project_name}-security-group"
  description = "Allow SSH from local IP and HTTP from the internet"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.project_name}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = var.my_ip_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.server_port
  to_port     = var.server_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}