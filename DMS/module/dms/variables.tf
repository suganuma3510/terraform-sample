variable "name" {}

variable "vpc_id" {}

variable "pri_subnet_ids" {}

variable "source_security_group_ids" {
  type = list(string)
}

variable "engine_version" {
  default = "3.4.7"
}

variable "instance_type" {
  default = "dms.t2.micro"
}

variable "storage" {
  type    = number
  default = 5
}


variable "source_db_config" {
  type = object({
    engine   = string
    endpoint = string
    db_name  = string
    username = string
    password = string
    port     = number
  })
}

# variable "target_db_config" {
#   type = object({
#     engine   = string
#     endpoint = string
#     db_name  = string
#     username = string
#     password = string
#     port     = number
#   })
# }

variable "target_opensearch_config" {
  type = object({
    engine            = string
    endpoint          = string
    username          = string
    password          = string
    elasticsearch_arn = string
  })
}
