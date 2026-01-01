output "cluster_id" {
  value = aws_docdb_cluster.cluster.id
}

output "cluster_endpoint" {
  value = aws_docdb_cluster.cluster.endpoint
}

output "docdb_security_group_id" {
  value = aws_security_group.docdb.id
}
