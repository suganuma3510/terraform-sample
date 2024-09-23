variable "name" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "ecs_cluster_id" {}

variable "security_groups" {
  type = list(string)
}

variable "load_balancer_config" {
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "task_role_arn" {}

variable "execution_role_arn" {}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "container_definitions" {
  type = string
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}
