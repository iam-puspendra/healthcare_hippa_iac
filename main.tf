terraform {
  backend "s3" {
    bucket         = "med-hipaa-tfstate-prod"
    key            = "hipaa-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    acl            = "private"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

# KMS key (global)
resource "aws_kms_key" "cmk" {
  description         = "HIPAA CMK for DocumentDB and S3"
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Shared CloudWatch log group
resource "aws_cloudwatch_log_group" "app" {
  name              = "hipaa-app-logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cmk.arn
}

# IAM module
module "iam" {
  source        = "./modules/iam"
  kms_key_arn   = aws_kms_key.cmk.arn
  log_group_arn = aws_cloudwatch_log_group.app.arn
}

# VPC module – all networking lives here
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_app_subnets = var.private_app_subnets
  private_db_subnets  = var.private_db_subnets
  availability_zones  = var.availability_zones
  region              = var.region
  enable_nat_gateway  = true
}

# Compute (ECS + ALB) – uses outputs from VPC + IAM
module "compute" {
  source                 = "./modules/compute"
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn

  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_app_subnet_ids = module.vpc.private_app_subnet_ids

  account_id  = var.account_id
  region      = var.region
  kms_key_arn = aws_kms_key.cmk.arn

  alb_security_group_id = module.vpc.alb_sg_id
  app_security_group_id = module.vpc.app_sg_id
}

# Database – uses VPC private DB subnets
module "database" {
  source                = "./modules/database"
  db_username           = "medadmin"
  db_password           = "secH1ppP55wD"
  kms_key_id            = aws_kms_key.cmk.arn
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  instance_count        = 1
}
