#--------------------------------------------------------------
# OpenSearch domain
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain
resource "aws_elasticsearch_domain" "default" {
  domain_name           = "${var.name}-opensearch"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type = var.instance_type
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
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
