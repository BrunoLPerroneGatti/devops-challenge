resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = data.aws_vpc.default.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-target-group"
  }
}

resource "aws_lb" "web" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]

  subnets = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}