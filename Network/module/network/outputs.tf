output "vpc_id" {
  value = aws_vpc.default.id
}

output "vpc_cidr" {
  value = aws_vpc.default.cidr_block
}

output "pub_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "pri_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "pub_subnet_cidr_blocks" {
  value = aws_subnet.public.*.cidr_block
}

output "pri_subnet_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}
