#--------------------------------------------------------------
# Secrets Manager
#--------------------------------------------------------------

# resource "random_password" "db_password" {
#   length           = 16
#   special          = true
#   override_special = "_!%^"
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
# resource "aws_secretsmanager_secret" "db_password" {
#   name = "${var.name}-db-password"
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
# resource "aws_secretsmanager_secret_version" "db_password" {
#   secret_id     = aws_secretsmanager_secret.db_password.id
#   secret_string = random_password.db_password.result
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret
data "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
  # depends_on = [aws_secretsmanager_secret.db_password]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
  # depends_on = [aws_secretsmanager_secret_version.db_password]
}
