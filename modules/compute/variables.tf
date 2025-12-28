variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN"
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB Security Group ID"
}

variable "private_app_subnet_ids" {
  type        = list(string)
  description = "List of private app subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of ECS task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ARN of ECS task role"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  type        = string
  description = "AWS region"
}
variable "app_security_group_id" {
  type        = string
  description = "Security group ID for ECS tasks"
}
