terraform {
  required_version = ">=v1.0.11"
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./module/network"

  name      = var.app_name
  vpc_cidr  = var.vpc_cidr
  azs       = var.azs
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "./module/iam"

  name = var.app_name
}

module "ec2" {
  source = "./module/ec2"

  app_name                  = var.app_name
  vpc_id                    = module.network.vpc_id
  vpc_cidr                  = module.network.vpc_cidr
  pub_subnet_ids            = module.network.pub_subnet_ids
  security_group            = module.network.ec2_security_group.id
  iam_instance_profile_name = module.iam.iam_instance_profile_name
  template_user_data        = local.template_user_data
}

locals {
  runners_name = "${var.app_name}-ci-autoscale"

  template_user_data = templatefile("${path.module}/template/user-data.tpl",
    {
      runners_name                = local.runners_name
      runners_gitlab_url          = var.runners_gitlab_url
      runners_token               = var.runners_token
      runners_config              = local.template_runner_config
      docker_machine_download_url = var.docker_machine_download_url
  })

  template_runner_config = templatefile("${path.module}/template/runner-config.tpl",
    {
      # Output to config.toml file
      runners_concurrent = var.runners_concurrent

      # [[runners]]
      runners_name  = local.runners_name
      gitlab_url    = var.runners_gitlab_url
      runners_token = ""
      runners_limit = var.runners_limit

      # [runners.cache]
      s3_access_key = var.s3_access_key
      s3_secret_key = var.s3_secret_key
      cache_path    = var.cache_path
      bucket_name   = var.bucket_name

      # [runners.machine]
      ci_access_key                 = var.ci_access_key
      ci_secret_key                 = var.ci_secret_key
      aws_region                    = var.region
      runners_aws_zone              = var.azs[0]
      runners_vpc_id                = module.network.vpc_id
      runners_subnet_id             = module.network.pub_subnet_ids[0]
      runners_security_group_name   = module.network.ec2_security_group.name
      runners_instance_type         = var.docker_machine_instance_type
      runners_ami                   = var.runners_ami
      runners_request_spot_instance = var.runners_request_spot_instance
      runners_spot_price_bid        = var.runners_spot_price_bid

      # [[runners.machine.autoscaling]]
      runners_idle_count = var.runners_idle_count
      runners_idle_time  = var.runners_idle_time
    }
  )
}
