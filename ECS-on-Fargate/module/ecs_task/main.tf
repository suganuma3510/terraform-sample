#--------------------------------------------------------------
#  ECS cluster
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# resource "aws_ecs_cluster" "cluster" {
#   name = "${var.name}-cluster"
# }

#--------------------------------------------------------------
#  ECS service
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "default" {
  name            = "${var.name}-service"
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.task_config.desired_count
  # launch_type     = "FARGATE"
  cluster         = var.ecs_cluster_arn

  # depends_on = [
  #   var.load_balancer_config
  # ]

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer_config[*]
    content {
      target_group_arn = var.load_balancer_config.target_group_arn
      container_name   = var.load_balancer_config.container_name
      container_port   = var.load_balancer_config.container_port
    }
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 0
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

#--------------------------------------------------------------
#  ECS task
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "default" {
  family                   = "${var.name}-task"
  container_definitions    = var.task_config.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_config.cpu
  memory                   = var.task_config.memory
  execution_role_arn       = var.iam_role_arn
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "ECS service security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ecs_ingress_app" {
  count = length(var.source_security_group_ids)

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "-1"
  source_security_group_id = element(var.source_security_group_ids, count.index)
  security_group_id        = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

#--------------------------------------------------------------
#  CloudWatch log gloup
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.name}-service"

  tags = {
    Application = "${var.name}-ecs-logs"
  }
}
