#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "rds-sg" {
  name        = "${var.app_name}-rds-sg"
  description = "RDS service security group for ${var.app_name}"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-sg of mysql"
  }
}

resource "aws_security_group_rule" "rds-sg-rule" {
  security_group_id = aws_security_group.rds-sg.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
}

#--------------------------------------------------------------
# Subnet group
#--------------------------------------------------------------

resource "aws_db_subnet_group" "rds-subnet-group" {
  name        = var.db_name
  description = "rds subnet group for ${var.db_name}"
  subnet_ids  = var.pri_subnet_ids
}

#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------

resource "aws_db_instance" "db" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.db_instance
  identifier             = var.db_name
  username               = var.db_username
  password               = data.aws_secretsmanager_secret_version.db_password.secret_string
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
}

#--------------------------------------------------------------
# Secrets Manager
#--------------------------------------------------------------

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.app_name}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

data "aws_secretsmanager_secret" "db_password" {
  name = "${var.app_name}-db-password"
  depends_on = [
    aws_secretsmanager_secret.db_password
  ]
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}