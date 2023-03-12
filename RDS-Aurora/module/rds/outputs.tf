output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "db_endpoint" {
  value = aws_rds_cluster.default.endpoint
}

output "db_reader_endpoint" {
  value = aws_rds_cluster.default.reader_endpoint
}

output "db_engine" {
  value = aws_rds_cluster.default.engine
}

output "db_name" {
  value = aws_rds_cluster.default.database_name
}

output "rds_cluster_id" {
  value = aws_rds_cluster.default.id
}

output "rds_cluster_instance_ids" {
  value = aws_rds_cluster_instance.default.*.id
}
