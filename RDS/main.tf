variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
variable "db_name" {}
variable "db_username" {}

terraform {
  required_version = "=v1.4.0"
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

module "jump-ec2" {
  source = "./module/ec2"

  app_name                  = var.name
  vpc_id                    = module.network.vpc_id
  pub_subnet_ids            = module.network.pub_subnet_ids
  iam_instance_profile_name = module.iam.iam_instance_profile_name

  remote_exec_commands = [
    "sudo yum -y install mysql"
  ]
  depend_resources = [
    module.rds.db_instance_id
  ]
}

module "secrets" {
  source = "./module/secrets"

  name = var.name
}

module "rds" {
  source = "./module/rds"

  app_name       = var.name
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = module.secrets.db_password
  vpc_id         = module.network.vpc_id
  pri_subnet_ids = module.network.pri_subnet_ids
}
