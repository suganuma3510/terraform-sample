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
  cidr_block              = var.pub_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-pub-${var.azs[count.index]}"
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

  subnet_id      = aws_subnet.pub-sub.*.id[count.index]
  route_table_id = aws_route_table.pub-rtb.id
}

#--------------------------------------------------------------
# Private subnet
#--------------------------------------------------------------

resource "aws_subnet" "pri-sub" {
  count = length(var.pri_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pri_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.name}-pri-${var.azs[count.index]}"
  }
}

resource "aws_route_table" "pri-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "${var.name}-pri-rtb"
  }
}

resource "aws_route_table_association" "pri-rtb-as" {
  count = length(var.pri_cidrs)

  subnet_id      = aws_subnet.pri-sub.*.id[count.index]
  route_table_id = aws_route_table.pri-rtb.id
}

#--------------------------------------------------------------
# NAT
#--------------------------------------------------------------

resource "aws_eip" "nat-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.pub-sub[0].id
  depends_on    = [aws_internet_gateway.igw]
}