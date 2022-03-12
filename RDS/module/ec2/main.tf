#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
  name = "${var.app_name}-ec2-sg"

  description = "EC2 service security group for ${var.app_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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
  iam_instance_profile        = aws_iam_instance_profile.systems_manager.name
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
# IAM Role
#--------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "MyRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_instance_profile" "systems_manager" {
  name = "MyInstanceProfile"
  role = aws_iam_role.role.name
}