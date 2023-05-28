output "lb_tg_arn" {
  value = aws_lb_target_group.default.arn
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}

# output "https_listener_arn" {
#   value = aws_lb_listener.https.arn
# }

output "lb_security_group_id" {
  value = aws_security_group.alb.id
}
