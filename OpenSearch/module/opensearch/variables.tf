variable "name" {}

variable "username" {}

variable "password" {}

variable "vpc_id" {}

variable "pri_subnet_ids" {}

variable "pri_subnet_cidr_blocks" {
  type = list(string)
}

variable "source_security_group_ids" {
  type    = list(string)
  default = []
}

variable "elasticsearch_version" {
  default     = "OpenSearch_1.3"
  description = "check available engines with 'aws opensearch list-versions'"
}

variable "instance_type" {
  default = "t3.small.elasticsearch"
}

variable "ebs_volume_size" {
  default = 10
}
