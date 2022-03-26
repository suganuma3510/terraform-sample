variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
# variable "elb_ingress_ports" { type = list(number) }

terraform {
  required_version = "=v1.0.11"

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
  source = "./module/network"

  name      = var.name
  vpc_cidr  = var.vpc_cidr
  azs       = var.azs
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "./module/iam"

  name = var.name
}

module "cloudwatch" {
  source = "./module/cloudwatch"

  name = var.name
}

module "elb" {
  source = "./module/elb"

  name           = var.name
  vpc_id         = module.network.vpc_id
  pub_subnet_ids = module.network.pub_subnet_ids
  # ingress_ports  = var.elb_ingress_ports
  # acm_id         = module.acm.acm_id
}

module "ecs" {
  source = "./module/ecs"

  name            = var.name
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.pri_subnet_ids
  lb_tg_arn       = module.elb.lb_tg_arn
  iam_role_arn    = module.iam.iam_role_arn
  logs_group_name = module.cloudwatch.logs_group_name
  # ingress_ports  = var.elb_ingress_ports

  service_config = {
    container_name = "nginx"
    container_port = 80
    desired_count  = 1
  }

  task_config = {
    definitions_file_name = "nginx_definition.json"
    ecr_image_uri         = "nginx:1.14"
    cpu                   = 256
    memory                = 512
    region                = var.region
  }
}
