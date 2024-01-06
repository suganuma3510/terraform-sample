variable "app_name" {}

variable "function_name" {}

# variable "vpc_id" {}

# variable "pri_subnet_ids" {}

# variable "pri_subnet_cidr_blocks" {
#   type = list(string)
# }

# variable "source_security_group_ids" {
#   type = list(string)
# }

variable "runtime" {}

variable "source_code_path" {}

variable "source_code_hash" {}

variable "memory_size" {
  default = 128
}

variable "timeout" {
  default = 30
}

variable "layers" {
  type    = list(string)
  default = []
}
