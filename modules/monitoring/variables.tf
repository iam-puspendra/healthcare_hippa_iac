variable "app_name" {
  description = "Application name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "kms_logs_arn" {
  description = "KMS key ARN for logs"
  type        = string
  default     = ""
}
