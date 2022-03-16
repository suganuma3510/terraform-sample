variable "name" {}

variable "vpc_id" {}

variable "pub_subnet_ids" {}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80]
}
