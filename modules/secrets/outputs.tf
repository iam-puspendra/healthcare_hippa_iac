output "app_secrets_arn" {
  value       = aws_secretsmanager_secret.app_secrets.arn
  description = "ARN of the comprehensive application secrets"
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.app_secrets.arn
  description = "ARN of app secrets (backward compatibility)"
}
