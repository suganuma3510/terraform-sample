variable "app_name" {}

variable "vpc_id" {}

variable "pub_subnet_ids" {}

variable "ingress_config" {
  type = list(object({
    port        = string
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  description = "list of ingress config"
}

variable "remote_exec_commands" {
  type    = list(string)
  default = []
}

variable "depend_resources" {
  type    = list(string)
  default = []
}
