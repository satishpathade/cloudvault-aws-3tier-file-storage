resource "aws_lb" "this" {
  name               = "${var.project_name}-pub-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [var.alb_sg_id]
  subnets         = var.public_subnet_ids
  tags = var.tags
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}