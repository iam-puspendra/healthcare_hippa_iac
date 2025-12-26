output "cluster_id" {
  value = aws_docdb_cluster.cluster.id
}

output "cluster_endpoint" {
  value = aws_docdb_cluster.cluster.endpoint
}
