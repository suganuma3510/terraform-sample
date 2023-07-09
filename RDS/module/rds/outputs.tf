output "db_instance_id" {
  value = aws_db_instance.rds.id
}

output "db_address" {
  value = aws_db_instance.rds.address
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}