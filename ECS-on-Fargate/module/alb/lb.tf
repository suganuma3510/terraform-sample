resource "aws_lb_target_group" "blog-alb-nginx-tg" {
  name        = "blog-alb-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.blog-vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 150
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = 120
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "blog_alb" {
  name               = "blog-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.blog-public-1a.id,
    aws_subnet.blog-public-1c.id
  ]
  security_groups = [
    aws_security_group.blog-alb-sg.id
  ]
  tags = {
    Name = "blog_alb"
  }
}

resource "aws_lb_listener" "blog_http_listener" {
  load_balancer_arn = aws_lb.blog_alb.arn
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

resource "aws_lb_listener" "blog_https_listener" {
  load_balancer_arn = aws_lb.blog_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.blog-acm.arn

  default_action {
    target_group_arn = aws_lb_target_group.blog-alb-nginx-tg.arn
    type             = "forward"
  }
}
