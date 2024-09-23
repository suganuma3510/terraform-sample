#--------------------------------------------------------------
#  ECS service
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "default" {
  name            = var.name
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.desired_count
  # launch_type     = "FARGATE"
  cluster = var.ecs_cluster_id

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
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

  # capacity_provider_strategy {
  #   base              = 1
  #   capacity_provider = "FARGATE"
  #   weight            = 0
  # }

  capacity_provider_strategy {
    # base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

#--------------------------------------------------------------
#  ECS task
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "default" {
  family                   = var.name
  container_definitions    = var.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  track_latest             = true

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform
  runtime_platform {
    cpu_architecture = var.cpu_architecture
  }
}
