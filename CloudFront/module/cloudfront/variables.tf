variable "name" {}

variable "s3_bucket_id" {}

variable "s3_bucket_regional_domain_name" {}

variable "cf_functions_arns" {
  type = map(string)
}

locals {
  ordered_cache_behaviors = [
    # {
    #   allowed_methods        = list(string)
    #   cached_methods         = list(string)
    #   compress               = bool
    #   default_ttl            = number
    #   max_ttl                = number
    #   min_ttl                = number
    #   path_pattern           = string
    #   smooth_streaming       = bool
    #   target_origin_id       = string
    #   viewer_protocol_policy = string
    #   forwarded_values = object({
    #     headers                 = list(string)
    #     query_string            = bool
    #     query_string_cache_keys = list(string)
    #     cookies = object({
    #       forward = string
    #     })
    #   })
    #   lambda_function_association = object({
    #     event_type   = string
    #     include_body = bool
    #     lambda_arn   = string
    #   })
    #   function_association = object({
    #     event_type   = string
    #     function_arn = string
    #   })
    # },
    {
      path_pattern           = "/test/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      default_ttl            = 86400
      max_ttl                = 31536000
      min_ttl                = 0
      smooth_streaming       = false
      target_origin_id       = var.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      forwarded_values = {
        headers                 = []
        query_string            = false
        query_string_cache_keys = []
        cookies = {
          forward = "none"
        }
      }
      lambda_function_association = null
      function_association = {
        event_type   = "viewer-request"
        function_arn = lookup(var.cf_functions_arns, "add_index_html")
      }
    },
    {
      path_pattern           = "/error/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      default_ttl            = 86400
      max_ttl                = 31536000
      min_ttl                = 0
      smooth_streaming       = false
      target_origin_id       = var.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      forwarded_values = {
        headers                 = []
        query_string            = false
        query_string_cache_keys = []
        cookies = {
          forward = "none"
        }
      }
      lambda_function_association = null
      function_association        = null
    }
  ]
}
