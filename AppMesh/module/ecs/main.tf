#--------------------------------------------------------------
#  ECS cluster
#--------------------------------------------------------------

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"
}

#--------------------------------------------------------------
#  ECS service
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service
resource "aws_service_discovery_service" "default" {
  name = "${var.service.name}-${var.service_version}"
  dns_config {
    namespace_id = var.service.aws_service_discovery_private_dns_namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "default" {
  name                   = "${var.service.name}-${var.service_version}"
  cluster                = aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.default.arn
  desired_count          = length(var.subnets)
  enable_execute_command = true
  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_group_ids
  }
  service_registries {
    registry_arn = aws_service_discovery_service.default.arn
  }
  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "default" {
  family                   = "${var.service.name}-${var.service_version}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  container_definitions = jsonencode(
    [
      {
        "name" : var.service.name,
        "image" : var.service_image,
        "repositoryCredentials" : {
          "credentialsParameter" : var.registry_token
        },
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : var.service_port,
            "hostPort" : var.service_port,
            "protocol" : "tcp"
          }
        ],
        "healthCheck" : {
          "command" : [
            "CMD-SHELL",
            "wget -t 1 -T 5 localhost:${var.service_port}/health -q -O - > /dev/null 2>&1"
          ],
          "startPeriod" : 10,
          "interval" : 5,
          "timeout" : 2,
          "retries" : 3,
        },
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-create-group" : "true",
            "awslogs-group" : var.service.aws_cloudwatch_log_group.name,
            "awslogs-region" : var.aws_region,
            "awslogs-stream-prefix" : var.service_version,
          }
        },
        "environment" : [for n, v in var.service_environments : { name : n, value : v }],
        "dependsOn" : [
          {
            "containerName" : "envoy",
            "condition" : "HEALTHY"
          }
        ]
      },
      {
        "name" : "envoy",
        "image" : var.envoy_image,
        "user" : "1337",
        "essential" : true,
        "environment" : [
          {
            "name" : "APPMESH_RESOURCE_ARN",
            "value" : aws_appmesh_virtual_node.default.arn
          },
          {
            "name" : "ENABLE_ENVOY_XRAY_TRACING",
            "value" : "1"
          },
        ],
        "healthCheck" : {
          "command" : [
            "CMD-SHELL",
            "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
          ],
          "startPeriod" : 10,
          "interval" : 5,
          "timeout" : 2,
          "retries" : 3,
        },
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-create-group" : "true",
            "awslogs-group" : var.service.aws_cloudwatch_log_group.name,
            "awslogs-region" : var.aws_region,
            "awslogs-stream-prefix" : var.service_version,
          }
        },
      },
      {
        "name" : "xray-daemon",
        "image" : "public.ecr.aws/xray/aws-xray-daemon",
        "user" : "1337",
        "essential" : true,
        "cpu" : 32,
        "memoryReservation" : 256,
        "portMappings" : [
          {
            "containerPort" : 2000,
            "protocol" : "udp"
          }
        ]
      }
    ]
  )
  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts           = "${var.service_port},2000"
      IgnoredUID         = "1337"
      ProxyIngressPort   = 15000
      ProxyEgressPort    = 15001
      EgressIgnoredPorts = join(",", var.egressIgnoredPorts)
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_route
resource "aws_appmesh_route" "default" {
  name                = "${var.service.name}-${var.service_version}-route"
  mesh_name           = var.service.aws_appmesh_mesh.name
  virtual_router_name = var.service.aws_appmesh_virtual_router.name

  spec {
    http_route {
      match {
        prefix = "/"
        dynamic "header" {
          for_each = var.http_headers
          content {
            name = header.key
            dynamic "match" {
              for_each = header.value
              content {
                exact = match.value
              }
            }
          }
        }
      }
      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.default.name
          weight       = 100
        }
      }
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node
resource "aws_appmesh_virtual_node" "default" {
  name      = "${var.service.name}-${var.service_version}"
  mesh_name = var.service.aws_appmesh_mesh.name

  spec {
    listener {
      port_mapping {
        port     = var.service_port
        protocol = "http"
      }
      health_check {
        protocol            = "tcp"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }
    service_discovery {
      dns {
        hostname = "${var.service.name}-${var.service_version}.${var.service.domain}"
      }
    }
    backend {
      virtual_service {
        virtual_service_name = var.aws_appmesh_virtual_service_gateway.name
      }
    }
  }

  tags = var.tags
}
