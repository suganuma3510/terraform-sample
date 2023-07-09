variable "app_name" {}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "source_security_group_ids" {
  type = list(string)
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0.33"
}

variable "db_instance" {
  default = "db.t2.micro"
}