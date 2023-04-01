variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_port" {}
variable "opensearch_username" {}
variable "opensearch_password" {}

terraform {
  required_version = "=v1.4.0"
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "../Network/module/network"

  name      = var.name
  vpc_cidr  = var.vpc_cidr
  azs       = var.azs
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "appmesh" {
  source   = "./module/appmesh"
  for_each = local.service

  service_name                                = each.value.name
  aws_service_discovery_private_dns_namespace = aws_service_discovery_private_dns_namespace.default
  aws_appmesh_mesh                            = aws_appmesh_mesh.default
  aws_appmesh_virtual_gateway                 = aws_appmesh_virtual_gateway.default
  listener_port                               = var.container_port
  tags                                        = local.tags
}

module "ecs" {
  source = "./module/ecs"

  aws_region         = var.aws_region
  service            = data.terraform_remote_state.common.outputs.user_service
  service_version    = "dev"
  aws_ecs_cluster    = data.terraform_remote_state.common.outputs.ecs_cluster
  subnets            = data.terraform_remote_state.common.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.common.outputs.security_group_app_id]
  task_role_arn      = data.terraform_remote_state.common.outputs.ecs_task_role_arn
  execution_role_arn = data.terraform_remote_state.common.outputs.ecs_task_role_execution_arn
  service_image      = local.docker_registry
  registry_token     = data.terraform_remote_state.common.outputs.registry_token_arn

  service_port = var.container_port
  service_environments = {
    "PORT"         = var.container_port
    "DATABASE_URL" = "mysql://root:${var.db_name}@${var.db_private_ip}:3306/default_user"
    "REDIS_URL"    = "redis://${var.db_private_ip}:6379"
  }
  envoy_image = local.envoy_image
  egressIgnoredPorts = [
    3306
  ]
  aws_appmesh_virtual_service_gateway = data.terraform_remote_state.common.outputs.appmesh_gateway
  tags                                = local.tags
}
