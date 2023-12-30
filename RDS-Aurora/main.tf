variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
variable "db_name" {}
variable "db_username" {}

terraform {
  required_version = "=v1.5.5"
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
  source = "../RDS/module/ec2"

  app_name   = var.name
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.pri_subnet_ids
}

module "rds-aurora" {
  source = "./module/rds"

  app_name                  = var.name
  db_name                   = var.db_name
  db_username               = var.db_username
  vpc_id                    = module.network.vpc_id
  pri_subnet_ids            = module.network.pri_subnet_ids
  pri_subnet_cidr_blocks    = module.network.pri_subnet_cidr_blocks
  source_security_group_ids = [module.jump-ec2.ec2_security_group_id]
}
