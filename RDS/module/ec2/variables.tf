variable "app_name" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "depend_resources" {
  type    = list(string)
  default = []
}
