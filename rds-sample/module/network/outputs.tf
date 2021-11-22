output "vpc_id" { value = aws_vpc.vpc.id }

output "vpc_cidr" { value = aws_vpc.vpc.cidr_block }

output "pub_subnet_ids" { value = aws_subnet.pub-sub.*.id }

output "pri_subnet_ids" { value = aws_subnet.pri-sub.*.id }