data "aws_ami" "devops-challenge" {
  most_recent = true
  owners      = ["self"]
}

resource "aws_launch_template" "web" {
  name_prefix = "${var.project_name}-"

  image_id      = data.aws_ami.devops-challenge.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id]

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.project_name
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.project_name}-asg"

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.web.arn]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.project_name
    propagate_at_launch = true
  }
}