# =============================================================================
# VARIABLES - Admin CloudFront Module
# =============================================================================

variable "environment" {
  type        = string
  description = "Environment name (e.g., production, staging)"
  default     = "production"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the Application Load Balancer"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of the ALB for origin access"
}
