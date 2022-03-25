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
  desired_count   = var.service_config.desired_count
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.cluster.arn

  depends_on = [
    var.lb_tg_arn
  ]

  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.lb_tg_arn
    container_name   = var.service_config.container_name
    container_port   = var.service_config.container_port
  }
}

#--------------------------------------------------------------
#  ECS task
#--------------------------------------------------------------

data "template_file" "container-definitions" {
  template = file("./module/ecs/task/${var.task_config.definitions_file_name}")
  vars = {
    SERVICE_NAME = var.service_config.container_name
    ECR_ARN      = var.task_config.ecr_image_uri
    LOGS_GROUP_NAME = aws_cloudwatch_log_group.cloudwatch.name
    REGION = var.task_config.region
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name}-task"
  container_definitions    = data.template_file.container-definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_config.cpu
  memory                   = var.task_config.memory
  execution_role_arn       = var.iam_role_arn
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}

#--------------------------------------------------------------
#  CloudWatch log gloup
#--------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "/ecs/${var.name}-service"

  tags = {
    Application = "${var.name}-ecs-logs"
  }
}