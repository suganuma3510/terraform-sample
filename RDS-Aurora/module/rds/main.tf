#--------------------------------------------------------------
# RDS Cluster
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "default" {
  cluster_identifier          = "${var.app_name}-aurora-cluster"
  engine                      = var.engine
  engine_version              = var.engine_version
  database_name               = var.db_name
  master_username             = var.db_username
  manage_master_user_password = true
  vpc_security_group_ids      = [aws_security_group.rds.id]
  db_subnet_group_name        = aws_db_subnet_group.rds.name

  skip_final_snapshot = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
}

#--------------------------------------------------------------
# RDS Cluster Instance
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "default" {
  count = var.db_instance_count

  identifier         = "${var.app_name}-aurora-cluster-instance-${count.index}"
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
  name   = "${var.app_name}-aurora-cluster-parameter-group"
  family = var.family

  dynamic "parameter" {
    for_each = var.parameter_groups
    iterator = parameter

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }
}

#--------------------------------------------------------------
# Subnet group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "rds" {
  name        = var.app_name
  description = "rds subnet group for ${var.app_name}"
  subnet_ids  = var.pri_subnet_ids
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "rds" {
  name        = "${var.app_name}-rds-sg"
  description = "RDS service security group for ${var.app_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.app_name}-rds-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "rds_ingress_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = var.pri_subnet_cidr_blocks
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_ingress_app" {
  count = length(var.source_security_group_ids)

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.source_security_group_ids, count.index)
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}
