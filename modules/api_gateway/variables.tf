# If you need vpc_id internally, add it here:
variable "vpc_id" {
  type = string
}
variable "subnet_ids" { # rename from "subnet_id" to plural
  description = "List of private subnet IDs for the VPC Link (at least 2 recommended)"
  type        = list(string)
}

variable "security_group_ids" { # rename from "app_sg_id"
  description = "Security group IDs for the VPC Link (usually the app/backend SG)"
  type        = list(string)
  default     = [] # or make required
}