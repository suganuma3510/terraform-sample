variable "name" {}

variable "vpc_id" {}

variable "pub_subnet_ids" {}

variable "lb_tg_arn" {}

variable iam_role_arn {}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80]
}
