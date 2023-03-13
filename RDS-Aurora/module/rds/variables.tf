variable "app_name" {}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "vpc_id" {}

variable "pri_subnet_ids" {}

variable "pri_subnet_cidr_blocks" {
  type = list(string)
}

variable "source_security_group_ids" {
  type = list(string)
}

variable "engine" {
  default = "aurora-mysql"
}

variable "engine_version" {
  default = "5.7.mysql_aurora.2.11.1"
}

variable "db_instance" {
  default = "db.t4g.medium"
}

variable "db_instance_count" {
  default = 1
}

variable "family" {
  default = "aurora-mysql5.7"
}

variable "parameter_groups" {
  type = map(string)
  default = {
    "time_zone" = "Asia/Tokyo"
  }
}
