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
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
}