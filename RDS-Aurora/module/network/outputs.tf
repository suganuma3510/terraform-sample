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
