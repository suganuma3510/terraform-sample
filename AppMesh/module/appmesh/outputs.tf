output "name" {
  value = var.service_name
}

output "domain" {
  value = var.aws_service_discovery_private_dns_namespace.name
}

output "aws_service_discovery_private_dns_namespace" {
  value = var.aws_service_discovery_private_dns_namespace
}

output "aws_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.default
}

output "aws_appmesh_mesh" {
  value = var.aws_appmesh_mesh
}

output "aws_appmesh_virtual_service" {
  value = aws_appmesh_virtual_service.default
}

output "aws_appmesh_virtual_router" {
  value = aws_appmesh_virtual_router.default
}
