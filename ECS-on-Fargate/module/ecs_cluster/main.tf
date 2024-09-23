#--------------------------------------------------------------
#  ECS cluster
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "default" {
  name = var.name
}
