///////////////////////////////////////////////////////////////////////////////
// ALB
//
resource "aws_security_group" "cnapp-sg-ingress" {
  name   = "cnapp-sg-ingress"
  vpc_id = aws_vpc.cnapp-vpc.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb" "cnapp-alb-ingress" {
  name                       = "cnapp-alb-ingress"
  internal                   = false
  ip_address_type            = "ipv4"
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.cnapp-subnet-public-ingress-1b.id,
    aws_subnet.cnapp-subnet-public-ingress-1c.id
  ]

  security_groups = [
    aws_security_group.cnapp-sg-ingress.id
  ]
}
resource "aws_alb_listener" "cnapp-alb-ingress" {
  load_balancer_arn = aws_alb.cnapp-alb-ingress.id
  port              = 80
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = 404
    }
  }
}
resource "aws_alb_target_group" "cnapp-tg-cnappdemo-blue" {
  name     = "cnapp-tg-cnappdemo-blue"
  protocol = "HTTP"
  port     = 80
  vpc_id   = aws_vpc.cnapp-vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/healthcheck"
    port                = 80
    interval            = 15
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}
resource "aws_lb_listener_rule" "cnapp-tg-cnappdemo-blue" {
  listener_arn = aws_alb_listener.cnapp-alb-ingress.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cnapp-tg-cnappdemo-blue.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
