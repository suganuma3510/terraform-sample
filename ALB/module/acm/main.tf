#--------------------------------------------------------------
#  AWS Certificate Manager
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate
data "aws_acm_certificate" "app" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}
