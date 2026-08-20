data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}


resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.default.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance.id]
  key_name                    = var.key_name

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = var.project_name
  }
}