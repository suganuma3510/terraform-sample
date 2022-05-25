variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

terraform {
  required_version = ">=v1.0.11"
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

module "ec2" {
  source = "./module/ec2"

  app_name                  = var.name
  vpc_id                    = module.network.vpc_id
  vpc_cidr                  = module.network.vpc_cidr
  pub_subnet_ids            = module.network.pub_subnet_ids
  iam_instance_profile_name = module.iam.iam_instance_profile_name
}
