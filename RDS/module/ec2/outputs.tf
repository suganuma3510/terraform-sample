output "private_key_pem" {
  value     = tls_private_key.ec2.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key.ec2.public_key_openssh
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}
