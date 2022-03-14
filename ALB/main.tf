variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
# ivariable "elb_ingress_ports" { type = list(number) }

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

module "elb" {
  source = "./module/elb"

  name           = var.name
  vpc_id         = module.network.vpc_id
  pub_subnet_ids = module.network.pub_subnet_ids
  # ingress_ports  = var.elb_ingress_ports
  # acm_id         = module.acm.acm_id
}
