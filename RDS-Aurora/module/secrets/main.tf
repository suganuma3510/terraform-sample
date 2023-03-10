#--------------------------------------------------------------
# Secrets Manager
#--------------------------------------------------------------

# resource "random_password" "db_password" {
#   length           = 16
#   special          = true
#   override_special = "_!%^"
# }

# resource "aws_secretsmanager_secret" "db_password" {
#   name = "${var.name}-db-password"
# }

# resource "aws_secretsmanager_secret_version" "db_password" {
#   secret_id     = aws_secretsmanager_secret.db_password.id
#   secret_string = random_password.db_password.result
# }

data "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
  # depends_on = [aws_secretsmanager_secret.db_password]
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
  # depends_on = [aws_secretsmanager_secret_version.db_password]
}
