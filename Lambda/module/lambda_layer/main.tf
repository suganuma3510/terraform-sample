#--------------------------------------------------------------
# Lambda layer
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version
resource "aws_lambda_layer_version" "default" {
  layer_name = "${var.app_name}-${var.layer_name}"

  filename         = var.source_code_path
  source_code_hash = var.source_code_hash

  compatible_runtimes = [var.runtime]
}
