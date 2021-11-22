variable "db_name" {}
variable "db_username" {}
variable "db_password" {}

module "rds" {
  source = "./module/rds"

  app_name       = var.name
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  vpc_id         = module.network.vpc_id
  pri_subnet_ids = module.network.pri_subnet_ids
}