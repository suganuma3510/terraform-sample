output "vpc_cidr" { value = aws_vpc.vpc.cidr_block }

output "pub_subnet_ids" { value = aws_subnet.pub-sub.*.id }

output "pri_subnet_ids" { value = aws_subnet.pri-sub.*.id }

output "http_listener_arn" {value = aws_lb_listener.http.arn}

output "https_listener_arn" {value = aws_lb_listener.https.arn}