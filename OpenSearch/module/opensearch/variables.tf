variable "name" {}

variable "username" {}

variable "password" {}

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
