variable "aws_service_discovery_private_dns_namespace" {}

variable "aws_appmesh_mesh" {}

variable "aws_appmesh_virtual_gateway" {}

variable "service_name" {}

variable "listener_port" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
