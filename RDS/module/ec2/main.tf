#--------------------------------------------------------------
# EC2
#--------------------------------------------------------------

resource "aws_instance" "ec2" {
  ami                         = "ami-011facbea5ec0363b"
  instance_type               = "t2.micro"
  subnet_id                   = var.pub_subnet_ids[0]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.ec2-key.key_name
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  iam_instance_profile        = var.iam_instance_profile_name
}

resource "aws_eip" "ec2-eip" {
  vpc      = true
  instance = aws_instance.ec2.id
}

#--------------------------------------------------------------
# Key Pair
#--------------------------------------------------------------

resource "aws_key_pair" "ec2-key" {
  key_name   = "common-ssh"
  public_key = tls_private_key._.public_key_openssh
}

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
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