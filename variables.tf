variable "region" {
  type    = string
  default = "us-east-1"
}
variable "account_id" {
  type        = string
  description = "AWS account ID"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnets" {
  description = "List of CIDR blocks for private app subnets"
  type        = list(string)
}

variable "private_db_subnets" {
  description = "List of CIDR blocks for private db subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "stripe_secret_key" {
  type        = string
  description = "Stripe Secret Key (Sensitive)"
  sensitive   = true
}