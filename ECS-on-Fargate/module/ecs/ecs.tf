# ECS cluster
resource "aws_ecs_cluster" "blog-ecs-cluster" {
  name = "blog-ecs-cluster"
}

# CloudWatch log gloup
resource "aws_cloudwatch_log_group" "blog-cloudwatch" {
  name = "blog-cloudwatch"

  tags = {
    Application = "blog-ecs"
  }
}

resource "aws_ecs_task_definition" "blog-nginx-task" {
  family                   = "blog-nginx-task"
  container_definitions    = file("./tasks/nginx_definition.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
}

resource "aws_ecs_service" "blog-nginx-ecs-service" {
  name            = "blog-nginx-ecs-service"
  task_definition = aws_ecs_task_definition.blog-nginx-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.blog-ecs-cluster.arn
  depends_on = [
    aws_iam_role_policy.ecs_service_role_policy,
    aws_lb.blog_alb
  ]
  network_configuration {
    security_groups = [
      aws_security_group.blog-ecs-service-sg.id
    ]
    subnets = [
      aws_subnet.blog-private-1a.id,
      aws_subnet.blog-private-1c.id
    ]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.blog-alb-nginx-tg.arn
    container_name   = "nginx"
    container_port   = "80"
  }
}
