#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------

resource "aws_vpc" "default" {
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

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.name}-igw"
  }
}

#--------------------------------------------------------------
# Public subnet
#--------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.pub_cidrs)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = element(var.pub_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-pub-${element(var.azs, count.index)}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.name}-pub-rtb"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.pub_cidrs)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#--------------------------------------------------------------
# Private subnet
#--------------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.pri_cidrs)

  vpc_id            = aws_vpc.default.id
  cidr_block        = element(var.pri_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-pri-${element(var.azs, count.index)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default.id
  }
  tags = {
    Name = "${var.name}-pri-rtb"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.pri_cidrs)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

#--------------------------------------------------------------
# NAT
#--------------------------------------------------------------

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.default]
}
