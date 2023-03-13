output "certificate_arn" {
  value = data.aws_acm_certificate.app.arn
}
