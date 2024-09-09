#--------------------------------------------------------------
# CloudFront
#--------------------------------------------------------------

# TODO
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
# resource "aws_cloudfront_origin_access_control" "lambda" {
#   name                              = "${var.name}-oac"
#   description                       = "OAC Policy for lambda"
#   origin_access_control_origin_type = "lambda"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

resource "aws_cloudfront_origin_access_control" "s3_default" {
  name                              = "${var.s3_bucket_id}-oac"
  description                       = "OAC policy for s3 ${var.s3_bucket_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "default" {
  # aliases         = ["hoge.example.com"]
  comment         = var.name
  enabled         = true
  is_ipv6_enabled = true

  # TODO
  # origin {
  #   domain_name = aws_lb.default.dns_name
  #   origin_id   = local.origin_id.app
  #   custom_origin_config {
  #     http_port                = 80
  #     https_port               = 443
  #     origin_protocol_policy   = "https-only"
  #     origin_ssl_protocols     = ["TLSv1.1", "TLSv1.2"]
  #     origin_keepalive_timeout = 60
  #     origin_read_timeout      = 60
  #   }
  # }

  origin {
    origin_id                = var.s3_bucket_id
    domain_name              = var.s3_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_default.id
  }

  # TODO
  # origin {
  #   domain_name              = "xxxxxxxx.lambda-url.ap-northeast-1.on.aws"
  #   origin_id                = local.origin_id.lambda
  #   origin_access_control_id = aws_cloudfront_origin_access_control.lambda.id
  #   custom_origin_config {
  #     http_port                = 80
  #     https_port               = 443
  #     origin_protocol_policy   = "https-only"
  #     origin_ssl_protocols     = ["TLSv1.2"]
  #     origin_keepalive_timeout = 60
  #     origin_read_timeout      = 60
  #   }
  # }

  # TODO
  # logging_config {
  #   bucket          = "tamahiyoapp-logs.s3.amazonaws.com"
  #   include_cookies = false
  #   prefix          = "CloudFront"
  # }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/error/404.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/error/404.html"
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    target_origin_id       = var.s3_bucket_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers      = ["Host"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.ordered_cache_behaviors

    content {
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
      min_ttl                = ordered_cache_behavior.value.min_ttl
      path_pattern           = ordered_cache_behavior.value.path_pattern
      smooth_streaming       = ordered_cache_behavior.value.smooth_streaming
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      forwarded_values {
        headers                 = ordered_cache_behavior.value.forwarded_values.headers
        query_string            = ordered_cache_behavior.value.forwarded_values.query_string
        query_string_cache_keys = ordered_cache_behavior.value.forwarded_values.query_string_cache_keys
        cookies {
          forward = ordered_cache_behavior.value.forwarded_values.cookies.forward
        }
      }
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association == null ? [] : [ordered_cache_behavior.value.lambda_function_association]
        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lambda_function_association.value.include_body
          lambda_arn   = lambda_function_association.value.lambda_arn
        }
      }
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association == null ? [] : [ordered_cache_behavior.value.function_association]
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # acm_certificate_arn            = var.acm_certificate_arn
    # cloudfront_default_certificate = false
    # minimum_protocol_version       = "TLSv1.2_2018"
    # ssl_support_method             = "sni-only"
  }
}

