resource "aws_route53_zone" "blog-host-zone" {
  name = "media-application.com"
}

resource "aws_route53_record" "blog-host-zone-record" {
  zone_id = aws_route53_zone.blog-host-zone.zone_id
  name    = aws_route53_zone.blog-host-zone.name
  type    = "A"

  alias {
    name                   = aws_lb.blog_alb.dns_name
    zone_id                = aws_lb.blog_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "blog-certificate" {
  domain_name       = aws_route53_zone.blog-host-zone.name
  validation_method = "DNS"
}

data "aws_acm_certificate" "blog-acm" {
  domain = "media-application.com"
}

output "blog-acm-arm" {
  value = data.aws_acm_certificate.blog-acm.arn
}
