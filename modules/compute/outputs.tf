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

output "alb_listener_arn" {
  description = "ARN of ALB listener for routing rules"
  value       = aws_lb_listener.frontend.arn
}

output "backend_alb_dns_name" {
  description = "DNS name of backend ALB"
  value       = aws_lb.backend_alb.dns_name
}

output "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace"
  value       = aws_service_discovery_private_dns_namespace.hipaa.id
}
