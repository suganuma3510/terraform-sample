#--------------------------------------------------------------
#  ECS cluster
#--------------------------------------------------------------

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"
}

#--------------------------------------------------------------
#  ECS service
#--------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name            = "${var.name}-service"
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.cluster.arn
  # depends_on = [
  #   aws_iam_role_policy.ecs_service_role_policy,
  #   aws_lb.blog_alb
  # ]

  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = var.pub_subnet_ids
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.alb-tg.arn
  #   container_name   = "nginx"
  #   container_port   = "80"
  # }
}

#--------------------------------------------------------------
#  ECS task
#--------------------------------------------------------------

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name}-task"
  container_definitions    = file("./module/ecs/task/nginx_definition.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  # execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  # task_role_arn            = aws_iam_role.ecs_execution_role.arn
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ecs-sg" {
  name        = "${var.name}-ecs-sg"
  description = "ECS security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port

    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

#--------------------------------------------------------------
#  CloudWatch log gloup
#--------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "${var.name}-cloudwatch"

  tags = {
    Application = "${var.name}-ecs-cloudwatch"
  }
}
