resource "aws_lb" "public_lb" {
  name               = trim(substr("${var.stack_name}-lb", 0, 32), "-")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb.id, aws_security_group.backend_ecs.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "public_lb_http" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "public_lb_https" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.backend.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_backend.arn
  }
}

resource "aws_lb_target_group" "ecs_backend" {
  name                 = trim(substr("${var.stack_name}-ecs-tg", 0, 32), "-")
  port                 = var.app_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 60
}