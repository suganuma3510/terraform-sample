#--------------------------------------------------------------
# IAM Policy
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy.html
resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}
