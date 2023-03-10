variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "db_name" {}
variable "db_username" {}

terraform {
  required_version = "=v1.1.9"
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
