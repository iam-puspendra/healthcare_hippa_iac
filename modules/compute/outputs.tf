output "cluster_id" {
  value = aws_ecs_cluster.app.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
