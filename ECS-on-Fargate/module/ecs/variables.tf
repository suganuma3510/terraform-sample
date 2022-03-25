variable "name" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "lb_tg_arn" {}

variable iam_role_arn {}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80]
}

variable "service_config" {
  type = object({
    container_name = string
    container_port = number
    desired_count  = number
  })
  description = "object of ecs service config"
}

variable "task_config" {
  type = object({
    definitions_file_name = string
    ecr_image_uri         = string
    cpu                   = number
    memory                = number
    region                = string
  })
  description = "object of ecs task config"
}