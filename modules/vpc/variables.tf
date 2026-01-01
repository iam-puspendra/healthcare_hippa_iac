variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "private_app_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private app subnets"
}

variable "private_db_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private db subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Toggle NAT Gateway creation"
  type        = bool
  default     = false
}