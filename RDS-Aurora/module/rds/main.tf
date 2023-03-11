#--------------------------------------------------------------
# RDS Cluster
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "default" {
  cluster_identifier     = "${var.db_name}-aurora-cluster"
  engine                 = var.engine
  engine_version         = var.engine_version
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  skip_final_snapshot = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
}

#--------------------------------------------------------------
# RDS Cluster Instance
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "default" {
  count = 2

  identifier         = "${var.db_name}-aurora-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id

  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version
  instance_class       = var.db_instance
  db_subnet_group_name = aws_rds_cluster.default.db_subnet_group_name
}

#--------------------------------------------------------------
# RDS Cluster parameter
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group
resource "aws_rds_cluster_parameter_group" "default" {
  name   = "${var.db_name}-aurora-cluster-parameter-group"
  family = "aurora-mysql5.7"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

#--------------------------------------------------------------
# Subnet group
#--------------------------------------------------------------

resource "aws_db_subnet_group" "rds" {
  name        = var.db_name
  description = "rds subnet group for ${var.db_name}"
  subnet_ids  = var.pri_subnet_ids
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${var.app_name}-rds-sg"
  description = "RDS service security group for ${var.app_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-sg"
  }
}