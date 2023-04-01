#--------------------------------------------------------------
# OpenSearch domain
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain
resource "aws_elasticsearch_domain" "default" {
  domain_name           = "${var.name}-opensearch"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = length(var.pri_subnet_ids)
    # zone_awareness_enabled = true
    # zone_awareness_config {
    #   availability_zone_count = length(var.pri_subnet_ids)
    # }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
  }

  vpc_options {
    subnet_ids         = var.pri_subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.username
      master_user_password = var.password
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    # https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-es-8
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  # cognito_options {
  #   enabled          = true
  #   identity_pool_id = ""
  #   role_arn         = ""
  #   user_pool_id     = ""
  # }

  tags = {
    Name = "${var.name}-opensearch-domain"
  }
}

#--------------------------------------------------------------
# OpenSearch domain policy
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain_policy
resource "aws_elasticsearch_domain_policy" "default" {
  domain_name = aws_elasticsearch_domain.default.domain_name

  # https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/fgac.html#fgac-recommendations
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "es:*",
            "Resource": "${aws_elasticsearch_domain.default.arn}/*"
        }
    ]
}
POLICIES
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "opensearch" {
  name        = "${var.name}-opensearch-sg"
  description = "OpenSearch service security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-opensearch-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "opensearch_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "opensearch_ingress_sg" {
  count = length(var.source_security_group_ids)

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.source_security_group_ids, count.index)
  security_group_id        = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "opensearch_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opensearch.id
}
