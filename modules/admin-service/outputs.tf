# =============================================================================
# OUTPUTS - Admin Service Module
# =============================================================================

output "admin_service_name" {
  description = "Name of the admin ECS service"
  value       = aws_ecs_service.admin.name
}

output "admin_task_definition_arn" {
  description = "ARN of the admin task definition"
  value       = aws_ecs_task_definition.admin.arn
}

output "admin_target_group_arn" {
  description = "ARN of the admin target group"
  value       = aws_lb_target_group.admin.arn
}

output "admin_alb_dns_name" {
  description = "DNS name of the admin ALB"
  value       = aws_lb.admin.dns_name
}

output "admin_alb_arn" {
  description = "ARN of the admin ALB"
  value       = aws_lb.admin.arn
}

output "admin_alb_listener_arn" {
  description = "ARN of the admin ALB listener"
  value       = aws_lb_listener.admin.arn
}

output "admin_security_group_id" {
  description = "ID of the admin security group"
  value       = aws_security_group.admin.id
}

output "admin_autoscaling_target_arn" {
  description = "ARN of the admin auto-scaling target"
  value       = aws_appautoscaling_target.admin.arn
}

output "admin_service_discovery_service_arn" {
  description = "ARN of the admin service discovery service (if enabled)"
  value       = var.enable_service_discovery ? aws_service_discovery_service.admin[0].arn : null
}

output "admin_log_group_name" {
  description = "Name of the admin CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.admin[0].name : var.log_group_name
}
