#--------------------------------------------------------------
# Lambda
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function.html
resource "aws_lambda_function" "default" {
  function_name = "${var.app_name}-${var.function_name}"
  runtime       = var.runtime

  filename         = var.source_code_path
  source_code_hash = var.source_code_hash
  handler          = "index.lambda_handler"
  memory_size      = var.memory_size
  timeout          = var.timeout

  role   = aws_iam_role.default.arn
  layers = var.layers
}

#--------------------------------------------------------------
# IAM Role
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "default" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  name = "${var.app_name}-${var.function_name}-iam-role"
}
