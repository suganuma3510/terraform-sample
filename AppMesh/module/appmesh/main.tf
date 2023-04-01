#--------------------------------------------------------------
#  AppMesh
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_gateway_route
resource "aws_appmesh_gateway_route" "default" {
  name                 = "${var.service_name}-route"
  mesh_name            = var.aws_appmesh_mesh.name
  virtual_gateway_name = var.aws_appmesh_virtual_gateway.name
  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = aws_appmesh_virtual_service.default.name
          }
        }
      }
      match {
        prefix = "/${var.service_name}/"
      }
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_service
resource "aws_appmesh_virtual_service" "default" {
  name      = "${var.service_name}.${var.aws_service_discovery_private_dns_namespace.name}"
  mesh_name = var.aws_appmesh_mesh.name
  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.default.name
      }
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_router
resource "aws_appmesh_virtual_router" "default" {
  name      = "${var.service_name}-router"
  mesh_name = var.aws_appmesh_mesh.name
  spec {
    listener {
      port_mapping {
        port     = var.listener_port
        protocol = "http"
      }
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.service_name}.${var.aws_service_discovery_private_dns_namespace.name}"
  retention_in_days = 30
}
