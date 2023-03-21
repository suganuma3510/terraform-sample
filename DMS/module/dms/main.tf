#--------------------------------------------------------------
# DMS Replication instance
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance
resource "aws_dms_replication_instance" "default" {
  replication_instance_id    = "${var.name}-dms-replication-instance"
  engine_version             = var.engine_version
  replication_instance_class = var.instance_type
  allocated_storage          = var.storage

  multi_az                    = false
  replication_subnet_group_id = aws_dms_replication_subnet_group.default.id
  vpc_security_group_ids      = [aws_security_group.dms.id]

  preferred_maintenance_window = "sun:10:30-sun:14:30"

  apply_immediately          = true
  auto_minor_version_upgrade = false
}

#--------------------------------------------------------------
# DMS Endpoint
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-${var.source_db_config.db_name}-endpoint-for-${var.name}"
  endpoint_type = "source"

  engine_name   = var.source_db_config.engine
  server_name   = var.source_db_config.endpoint
  database_name = var.source_db_config.db_name
  username      = var.source_db_config.username
  password      = var.source_db_config.password
  port          = var.source_db_config.port
}

# resource "aws_dms_endpoint" "target" {
#   endpoint_id   = "target-${var.source_db_config.db_name}-endpoint-for-${var.name}"
#   endpoint_type = "target"

#   engine_name   = var.target_db_config.engine
#   server_name   = var.target_db_config.endpoint
#   database_name = var.target_db_config.db_name
#   username      = var.target_db_config.username
#   password      = var.target_db_config.password
#   port          = 3306
# }

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-opensearch-endpoint-for-${var.name}"
  endpoint_type = "target"

  engine_name = var.target_opensearch_config.engine

  # https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.Elasticsearch.html
  elasticsearch_settings {
    endpoint_uri            = "https://${var.target_opensearch_config.endpoint}"
    service_access_role_arn = aws_iam_role.dms_opensearch.arn
  }
}

#--------------------------------------------------------------
# DMS replication task
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_task
resource "aws_dms_replication_task" "default" {
  replication_task_id = "${var.name}-replication-task"

  replication_instance_arn = aws_dms_replication_instance.default.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  migration_type            = "full-load-and-cdc"
  cdc_start_time            = time_static.cdc.unix
  replication_task_settings = file("${path.module}/task/replication_task_setting.json")
  table_mappings            = file("${path.module}/task/table_mapping.json")
}

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static
resource "time_static" "cdc" {}

#--------------------------------------------------------------
# Subnet group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_subnet_group
resource "aws_dms_replication_subnet_group" "default" {
  replication_subnet_group_id          = "${var.name}-dms-subnet-group"
  replication_subnet_group_description = "dms subnet group for ${var.name}"
  subnet_ids                           = var.pri_subnet_ids
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "dms" {
  name        = "${var.name}-dms-sg"
  description = "DMS service security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-dms-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "dms_ingress_app" {
  count = length(var.source_security_group_ids)

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.source_security_group_ids, count.index)
  security_group_id        = aws_security_group.dms.id
}

resource "aws_security_group_rule" "dms_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dms.id
}

#--------------------------------------------------------------
# IAM Role
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "dms_opensearch" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "dms_opensearch" {
  name               = "${var.name}-dms-role"
  assume_role_policy = data.aws_iam_policy_document.dms_opensearch.json
  inline_policy {
    name = "${var.name}-dms-inline-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "es:ESHttpDelete",
            "es:ESHttpGet",
            "es:ESHttpHead",
            "es:ESHttpPost",
            "es:ESHttpPut"
          ]
          Effect   = "Allow"
          Resource = "${var.target_opensearch_config.elasticsearch_arn}/*"
        },
      ]
    })
  }
}
