#--------------------------------------------------------------
# CloudFront Functions
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function
resource "aws_cloudfront_function" "default" {
  name    = var.name
  runtime = "cloudfront-js-2.0"
  comment = var.comment
  publish = true
  code    = file("${var.file_path}")
}
