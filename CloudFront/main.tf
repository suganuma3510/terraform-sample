variable "region" {}
variable "name" {}
variable "env" {}

locals {
  name_prefix = "${var.env}-${var.name}"
}

terraform {
  required_version = "=v1.9.5"
}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "./module/s3_oac"

  name                         = local.name_prefix
  cloudfront_distribution_arns = [module.cloudfront.cloudfront_distribution_arn]
}

module "cf_functions" {
  source = "./module/cf_functions"

  name      = local.name_prefix
  comment   = ""
  file_path = "./src/add_index_html.js"
}

module "cloudfront" {
  source = "./module/cloudfront"

  name                           = local.name_prefix
  s3_bucket_id                   = module.s3.s3_bucket_id
  s3_bucket_regional_domain_name = module.s3.s3_bucket_regional_domain_name
  cf_functions_arns = {
    add_index_html = module.cf_functions.cloudfront_function_arn
  }
}
