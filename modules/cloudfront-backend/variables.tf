variable "backend_alb_dns_name" {
  type        = string
  description = "Backend ALB DNS name for backend API"
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB Security Group ID"
}
