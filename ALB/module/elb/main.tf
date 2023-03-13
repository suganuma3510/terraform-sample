#--------------------------------------------------------------
#  Elastic Load Balancing
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "default" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = var.pub_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = {
    Name = "${var.name}-alb"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "default" {
  name        = "${var.name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.default.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.default.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn

#   default_action {
#     target_group_arn = aws_lb_target_group.default.arn
#     type             = "forward"
#   }
# }

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}


resource "aws_security_group_rule" "alb_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.alb.id
}
