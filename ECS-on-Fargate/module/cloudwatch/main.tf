#--------------------------------------------------------------
#  CloudWatch log gloup
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}
