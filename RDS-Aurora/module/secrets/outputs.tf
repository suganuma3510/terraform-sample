output "db_password" {
  value = data.aws_secretsmanager_secret_version.db_password.secret_string
}
