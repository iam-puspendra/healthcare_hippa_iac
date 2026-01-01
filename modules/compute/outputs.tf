output "cluster_id" {
  value = aws_ecs_cluster.app.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_api_endpoint" {
  value = "http://${aws_lb.alb.dns_name}/api"
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_arn_suffix" {
  value = aws_lb.alb.arn_suffix
}
