variable "db_username" {
  type        = string
  description = "Master username for DocumentDB"
}

variable "db_password" {
  type        = string
  description = "Master password for DocumentDB"
  sensitive   = true
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN for DocumentDB encryption"
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "List of private db subnet IDs"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where DocumentDB will be deployed"
}

variable "app_security_group_id" {
  type        = string
  description = "Security group ID of the ECS application"
}
