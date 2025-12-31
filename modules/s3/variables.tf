variable "data_bucket_name" {
  description = "Name of the S3 bucket for PHI/health data"
  type        = string
  
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for application logs"
  type        = string
  
}

variable "kms_s3_data_arn" {
  description = "KMS key ARN for encrypting PHI data bucket"
  type        = string
}

variable "kms_logs_arn" {
  description = "KMS key ARN for encrypting logs bucket"
  type        = string
}

variable "app_name" {
  description = "Application name for tagging"
  type        = string
  default     = "hipaa-app"
}
