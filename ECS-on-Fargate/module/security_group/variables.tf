variable "name" {}

variable "vpc_id" {}

variable "description" {
  type = string
}

variable "ingress_security_group_rules" {
  type = list(object({
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = string
  }))
  default = []
}

variable "ingress_cidr_blocks_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
