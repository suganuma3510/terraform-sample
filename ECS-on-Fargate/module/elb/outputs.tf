output "lb_tg_arn" { value = aws_lb_target_group.alb-tg.arn }

output "http_listener_arn" { value = aws_alb_listener.http.arn }

# output "https_listener_arn" { value = aws_alb_listener.https.arn }
