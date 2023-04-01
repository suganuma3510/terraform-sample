variable "aws_region" {}

variable "service" {}

variable "service_version" {}

variable "aws_ecs_cluster" {}

variable "task_role_arn" {}

variable "execution_role_arn" {}

variable "subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "load_balancer" {
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "service_port" {
  type = number
}

variable "service_image" {}

variable "registry_token" {}

variable "service_environments" {
  type    = map(string)
  default = {}}

variable "envoy_image" {}

variable "egressIgnoredPorts" {
  type = list(number)
}

variable "http_headers" {
  type    = map(any)
  default = {}
}

variable "aws_appmesh_virtual_service_gateway" {}

variable "tags" {
  type    = map(string)
  default = {}
}
