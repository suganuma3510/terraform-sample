variable "region" {}
variable "name" {}
# variable "vpc_cidr" {}
# variable "public_subnet_cidrs" { type = map(string) }
# variable "private_subnet_cidrs" { type = map(string) }

terraform {
  required_version = "=v1.6.6"
}

provider "aws" {
  region = var.region
}


#--------------------------------------------------------------
# Lambda common layer
#--------------------------------------------------------------

resource "terraform_data" "python_common_layer" {
  triggers_replace = {
    requirements_diff = filebase64("./sample_python_function/src/requirements.txt")
  }

  provisioner "local-exec" {
    command    = "make -C ./sample_python_function build"
    on_failure = fail
  }
}

data "archive_file" "python_common_layer" {
  depends_on = [
    terraform_data.python_common_layer,
  ]

  type        = "zip"
  source_dir  = "./sample_python_function/outputs/layer"
  output_path = "./sample_python_function/outputs/zip/python_common_layer.zip"
}

module "lambda_python_common_layer" {
  source = "./module/lambda_layer"

  app_name         = var.name
  layer_name       = "python_common_layer"
  runtime          = "python3.8"
  source_code_path = data.archive_file.python_common_layer.output_path
  source_code_hash = data.archive_file.python_common_layer.output_base64sha256
}

#--------------------------------------------------------------
# Lambda sample_python_function
#--------------------------------------------------------------

data "archive_file" "sample_python_function" {
  type        = "zip"
  source_dir  = "./sample_python_function/src"
  output_path = "./sample_python_function/outputs/zip/sample_python_function.zip"
}

module "lambda_sample_function" {
  source = "./module/lambda"

  app_name         = var.name
  function_name    = "sample_python_function"
  runtime          = "python3.8"
  source_code_path = data.archive_file.sample_python_function.output_path
  source_code_hash = data.archive_file.sample_python_function.output_base64sha256
  layers           = [module.lambda_python_common_layer.lambda_layer_version_arn]
}
