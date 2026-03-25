# =============================================================================
# VARIABLES - Admin Service Module
# =============================================================================

variable "environment" {
  type        = string
  description = "Environment name (e.g., production, staging)"
  default     = "production"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "account_id" {
  type        = string
  description = "AWS account ID for ECR image URI"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag for admin service"
  default     = "latest"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of existing ECS cluster"
  default     = "hipaa-ecs-cluster"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of ECS task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ARN of ECS task role for application permissions"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS tasks"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for admin ALB"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of the existing ALB"
}

variable "app_secrets_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret containing application secrets"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for ECS service logs"
  default     = "hipaa-app-logs"
}

variable "enable_service_discovery" {
  type        = bool
  description = "Enable AWS Cloud Map service discovery for internal communication"
  default     = false
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Service discovery namespace ID for internal communication"
  default     = ""
}

variable "create_log_group" {
  type        = bool
  description = "Whether to create a new CloudWatch log group"
  default     = false  # Set to false if using existing log group
}
