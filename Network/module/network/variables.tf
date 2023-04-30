variable "name" {}

variable "region" {}

variable "vpc_cidr" {}

variable "pub_cidrs" {
  type = map(string)
}

variable "pri_cidrs" {
  type = map(string)
}
