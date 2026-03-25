output "frontend_lifecycle_policy_id" {
  description = "ECR lifecycle policy ID for frontend"
  value       = aws_ecr_lifecycle_policy.frontend.id
}

output "backend_lifecycle_policy_id" {
  description = "ECR lifecycle policy ID for backend"
  value       = aws_ecr_lifecycle_policy.backend.id
}

output "admin_lifecycle_policy_id" {
  description = "ECR lifecycle policy ID for admin"
  value       = aws_ecr_lifecycle_policy.admin.id
}

output "frontend_repository_name" {
  description = "ECR repository name for frontend"
  value       = "frontend"
}

output "backend_repository_name" {
  description = "ECR repository name for backend"
  value       = "backend"
}

output "admin_repository_name" {
  description = "ECR repository name for admin"
  value       = "admin"
}
