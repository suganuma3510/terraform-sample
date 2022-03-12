variable "name" {}

variable "vpc_cidr" {}

variable "azs" {}

variable "pub_cidrs" { type = list(string) }

variable "pri_cidrs" { type = list(string) }