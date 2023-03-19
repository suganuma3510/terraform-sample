#--------------------------------------------------------------
# EC2
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2" {
  ami                         = "ami-011facbea5ec0363b"
  instance_type               = "t2.micro"
  subnet_id                   = var.pub_subnet_ids[0]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.ec2.key_name
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = var.iam_instance_profile_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "ec2" {
  vpc      = true
  instance = aws_instance.ec2.id
}

#--------------------------------------------------------------
# Key Pair
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "ec2" {
  key_name   = "common-ssh"
  public_key = tls_private_key.ec2.public_key_openssh
}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ec2" {
  name = "${var.app_name}-ec2-sg"

  description = "EC2 service security group for ${var.app_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = { for i in var.ingress_config : i.port => i }

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
# DB initialization
#--------------------------------------------------------------

# https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "db_setup" {
  count = length(var.remote_exec_commands) == 0 ? 0 : 1

  triggers_replace = [
    aws_instance.ec2.id
  ]

  connection {
    type        = "ssh"
    host        = aws_eip.ec2.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.ec2.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = var.remote_exec_commands
  }

  depends_on = [var.depend_resources]
}
