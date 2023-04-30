output "vpc_id" {
  value = aws_vpc.default.id
}

output "vpc_cidr" {
  value = aws_vpc.default.cidr_block
}

output "pub_subnet_ids" {
  value = [for value in aws_subnet.public : value.id]
}

output "pri_subnet_ids" {
  value = [for value in aws_subnet.private : value.id]
}

output "pub_subnet_cidr_blocks" {
  value = [for value in aws_subnet.public : value.cidr_block]
}

output "pri_subnet_cidr_blocks" {
  value = [for value in aws_subnet.private : value.cidr_block]
}
