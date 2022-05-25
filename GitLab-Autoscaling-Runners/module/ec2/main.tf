

#--------------------------------------------------------------
# AMI
#--------------------------------------------------------------
# aws ec2 describe-images --filters "Name=name,Values=amzn2-ami-kernel*" "Name=architecture,Values=x86_64" --query "sort_by(Images, &CreationDate)[].Name" --owners amazon --no-cli-pager
data "aws_ami" "amazon2_amd64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

#--------------------------------------------------------------
# EC2
#--------------------------------------------------------------

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon2_amd64.id
  instance_type          = "t3.micro"
  subnet_id              = var.pub_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  iam_instance_profile   = var.iam_instance_profile_name
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
  name = "${var.app_name}-ec2-sg"

  description = "EC2 service security group for ${var.app_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2376
    to_port     = 2376
    description = "Docker Machine"
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
