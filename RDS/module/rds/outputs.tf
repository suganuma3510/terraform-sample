output "db_instance_id" {
  value = aws_db_instance.rds.id
}

output "db_address" {
  value = aws_db_instance.rds.address
}
