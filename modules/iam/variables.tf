variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for IAM policies"
}

variable "log_group_arn" {
  type        = string
  description = "CloudWatch log group ARN for IAM policies"
}
