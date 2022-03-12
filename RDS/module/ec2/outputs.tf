output "private_key_pem" {
  value     = tls_private_key._.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key._.public_key_openssh
}
