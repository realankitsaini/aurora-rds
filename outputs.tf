output "aurora_cluster_writer_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
  description = "The main read-write connection cluster endpoint"
}

output "aurora_cluster_reader_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
  description = "The load-balanced read-only replica cluster endpoint"
}

output "aurora_database_name" {
  value       = aws_rds_cluster.aurora_cluster.database_name
  description = "Name of the target database application schema managed inside the cluster"
}