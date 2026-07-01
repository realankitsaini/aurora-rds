output "aurora_cluster_writer_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
  description = "The primary read-write cluster storage endpoint"
}

output "aurora_cluster_reader_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
  description = "The load-balanced read-only replica endpoint"
}

output "active_workspace_environment" {
  value       = terraform.workspace
  description = "The active workspace runtime environment footprint"
}