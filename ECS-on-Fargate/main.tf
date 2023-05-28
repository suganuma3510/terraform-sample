variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }

terraform {
  required_version = "=v1.4.0"

  # backend "s3" {
  #   bucket = "devday2022-bucket"
  #   key    = "terraform.tfstate"
  #   region = "ap-northeast-1"
  # }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "../Network/module/network"

  name      = var.name
  region    = var.region
  vpc_cidr  = var.vpc_cidr
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "./module/iam"

  name = var.name
}

module "elb" {
  source = "../ALB/module/elb"

  name           = var.name
  vpc_id         = module.network.vpc_id
  vpc_cidr       = module.network.vpc_cidr
  pub_subnet_ids = module.network.pub_subnet_ids
  # certificate_arn = module.acm.certificate_arn
}

#--------------------------------------------------------------
#  ECS
#--------------------------------------------------------------

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"
}

module "ecs_nginx" {
  source = "./module/ecs_task"

  name                      = var.name
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.pri_subnet_ids
  source_security_group_ids = [module.elb.lb_security_group_id]
  load_balancer_config = {
    target_group_arn = module.elb.lb_tg_arn
    container_name   = "nginx"
    container_port   = 80
  }
  iam_role_arn    = module.iam.iam_role_arn
  ecs_cluster_arn = aws_ecs_cluster.cluster.arn
  task_config     = local.task_config.nginx
}

locals {
  task_config = {
    nginx = {
      cpu           = 256
      memory        = 512
      desired_count = 1
      container_definitions = templatefile("${path.module}/template/nginx_definition.json",
        {
          SERVICE_NAME    = "nginx"
          ECR_ARN         = "nginx:1.14"
          LOGS_GROUP_NAME = "/ecs/${var.name}-service"
          REGION          = var.region
      })
    }
  }
}
