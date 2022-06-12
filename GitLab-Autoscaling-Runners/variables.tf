variable "region" {}

variable "app_name" {}

variable "vpc_cidr" {}

variable "azs" {}

variable "public_subnet_cidrs" { type = list(string) }

variable "private_subnet_cidrs" { type = list(string) }

variable "runners_gitlab_url" { default = "https://gitlab.com/" }

variable "runners_token" {}

variable "docker_machine_download_url" {}

variable "runners_concurrent" {}

variable "runners_limit" {}

variable "s3_access_key" {}

variable "s3_secret_key" {}

variable "cache_path" {}

variable "bucket_name" {}

variable "ci_access_key" {}

variable "ci_secret_key" {}

variable "docker_machine_instance_type" { default = "t3.small" }

variable "runners_ami" { default = "ami-0a3eb6ca097b78895" }

variable "runners_request_spot_instance" {}

variable "runners_spot_price_bid" {}

variable "runners_idle_count" {}

variable "runners_idle_time" {}
