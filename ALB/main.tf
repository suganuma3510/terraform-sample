variable "region" {}
variable "name" {}
variable "domain_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }

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

# module "acm" {
#   source = "./module/acm"

#   domain_name = var.domain_name
# }

module "elb" {
  source = "./module/elb"

  name           = var.name
  vpc_id         = module.network.vpc_id
  vpc_cidr       = module.network.vpc_cidr
  pub_subnet_ids = module.network.pub_subnet_ids
  # certificate_arn = module.acm.certificate_arn
}
