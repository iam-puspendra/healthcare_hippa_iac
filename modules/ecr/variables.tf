variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "production"
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "hipaa-app"
}
