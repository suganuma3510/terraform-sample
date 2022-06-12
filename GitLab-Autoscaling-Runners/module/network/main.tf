#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

#--------------------------------------------------------------
# Internet Gateway
#--------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-igw"
  }
}

#--------------------------------------------------------------
# Public subnet
#--------------------------------------------------------------

resource "aws_subnet" "pub-sub" {
  count = length(var.pub_cidrs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-pub-${element(var.azs, count.index)}"
  }
}

resource "aws_route_table" "pub-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.name}-pub-rtb"
  }
}

resource "aws_route_table_association" "pub-rtb-as" {
  count = length(var.pub_cidrs)

  subnet_id      = element(aws_subnet.pub-sub.*.id, count.index)
  route_table_id = aws_route_table.pub-rtb.id
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
  name = "${var.name}-ec2-sg"

  description = "EC2 service security group for ${var.name}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 2376
    to_port     = 2376
    description = "Docker Machine"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
