variable "name" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "source_security_group_ids" {
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

variable "iam_role_arn" {}

variable "ecs_cluster_arn" {}

variable "task_config" {
  type = object({
    cpu                   = number
    memory                = number
    desired_count         = number
    container_definitions = string
  })
  description = "object of ecs task config"
}
