output "elasticsearch_arn" {
  value = aws_elasticsearch_domain.default.arn
}

output "elasticsearch_domain" {
  value = aws_elasticsearch_domain.default.endpoint
}
