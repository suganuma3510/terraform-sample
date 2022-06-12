output "vpc_id" { value = aws_vpc.vpc.id }

output "vpc_cidr" { value = aws_vpc.vpc.cidr_block }

output "pub_subnet_ids" { value = aws_subnet.pub-sub.*.id }

output "ec2_security_group" { value = aws_security_group.ec2-sg }
