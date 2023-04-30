variable "region" {}
variable "name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
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
  region    = var.region
  vpc_cidr  = var.vpc_cidr
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "source-rds" {
  source = "../RDS-Aurora/module/rds"

  app_name                  = "source-rds"
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  vpc_id                    = module.network.vpc_id
  pri_subnet_ids            = module.network.pri_subnet_ids
  pri_subnet_cidr_blocks    = module.network.pri_subnet_cidr_blocks
  source_security_group_ids = [module.jump-ec2.ec2_security_group_id]
  parameter_groups = {
    "time_zone"     = "Asia/Tokyo",
    "binlog_format" = "ROW"
  }
}

# module "target-rds" {
#   source = "../RDS-Aurora/module/rds"

#   app_name                  = "target-rds"
#   db_name                   = var.db_name
#   db_username               = var.db_username
#   db_password               = var.db_password
#   vpc_id                    = module.network.vpc_id
#   pri_subnet_ids            = module.network.pri_subnet_ids
#   pri_subnet_cidr_blocks    = module.network.pri_subnet_cidr_blocks
#   source_security_group_ids = [module.jump-ec2.ec2_security_group_id]
# }

module "target-opensearch" {
  source = "../OpenSearch/module/opensearch"

  name                   = var.name
  username               = var.opensearch_username
  password               = var.opensearch_password
  vpc_id                 = module.network.vpc_id
  pri_subnet_ids         = [module.network.pri_subnet_ids[0]]
  pri_subnet_cidr_blocks = module.network.pri_subnet_cidr_blocks
  # source_security_group_ids = [module.dms.dms_security_group_id]
}

module "dms" {
  source = "./module/dms"

  name           = var.name
  vpc_id         = module.network.vpc_id
  pri_subnet_ids = module.network.pri_subnet_ids
  source_security_group_ids = [
    module.source-rds.db_security_group_id
    # module.target-rds.db_security_group_id
  ]
  source_db_config = {
    engine   = "aurora"
    endpoint = module.source-rds.db_reader_endpoint
    db_name  = var.db_name
    username = var.db_username
    password = var.db_password
    port     = var.db_port
  }
  # target_db_config = {
  #   engine   = "aurora"
  #   endpoint = module.target-rds.db_writer_endpoint
  #   db_name  = var.db_name
  #   username = var.db_username
  #   password = var.db_password
  #   port     = var.db_port
  # }
  target_opensearch_config = {
    engine            = "opensearch"
    endpoint          = module.target-opensearch.elasticsearch_domain
    username          = var.opensearch_username
    password          = var.opensearch_password
    elasticsearch_arn = module.target-opensearch.elasticsearch_arn
  }
# }

# module "jump-ec2" {
#   source = "../RDS/module/ec2"

#   app_name       = var.name
#   vpc_id         = module.network.vpc_id
#   pub_subnet_ids = module.network.pub_subnet_ids

#   remote_exec_commands = [
#     "sudo amazon-linux-extras install -y nginx1"
#   ]
#   depend_resources = concat(
#     module.source-rds.rds_cluster_instance_ids,
#     [
#       module.source-rds.rds_cluster_id
#     ]
#   )
# }
