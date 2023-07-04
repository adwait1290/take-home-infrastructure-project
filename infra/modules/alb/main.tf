# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# AWS Load Balancer resource
resource "aws_lb" "main" {
  # The environment name is prepended to yield a meaningful resource name
  name               = "${var.environment}-alb"
  # It is specified as an external (internet-facing) Load Balancer
  internal           = false
  load_balancer_type = "application"
  # A security group associated with the Load Balancer
  security_groups    = [var.alb_sg_id]
  # Subnets where the Load Balancer will span across
  subnets            = var.public_subnet_ids
  # Deletion protection is enabled to prevent unintentional deletion of the lb
  enable_deletion_protection = true
  tags = local.common_tags
}
# AWS Target Group for Load Balancer
resource "aws_lb_target_group" "tg" {
  # The tags are prepended with the name for easy identification
  name     = "${local.common_tags.Name}-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  # Session stickiness enabled for one day
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  # Health check configuration
  health_check {
    enabled             = true
    matcher = "200-499"
    interval            = 30
    path                = "/"
    timeout             = 15
  }

  # Ignore changes in health check lifecycle to avoid TCP protocol errors
  lifecycle {
    ignore_changes = [health_check]
  }

  tags = local.common_tags
}
# TODO: PICK ONE
# Listener for HTTP traffic
resource "aws_lb_listener" "http2" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  # Forward action sends traffic to the specified target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
# TODO: PICK ONE
# Listener for HTTP traffic
resource "aws_lb_listener" "http1" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Forward action sends traffic to the specified target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Listener for HTTPS traffic
resource "aws_lb_listener" "https_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # A certificate is attached for HTTPS
  certificate_arn   = var.cert_arn
  # Forward action sends traffic to the specified target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
