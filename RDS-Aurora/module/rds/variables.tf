variable "app_name" {}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "vpc_id" {}

variable "pri_subnet_ids" {}

variable "engine" {
  default = "aurora-mysql"
}

variable "engine_version" {
  default = "5.7.mysql_aurora.2.11.1"
}

variable "db_instance" {
  default = "db.t4g.medium"
}
