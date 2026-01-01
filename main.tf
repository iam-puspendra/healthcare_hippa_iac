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
  source          = "./modules/iam"
  app_name        = "hipaa-app"
  kms_key_arn     = aws_kms_key.cmk.arn
  log_group_arn   = aws_cloudwatch_log_group.app.arn
  db_secret_arn   = module.secrets.db_secret_arn
  app_secrets_arn = module.secrets.app_secrets_arn
  depends_on      = [module.secrets]
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
  docdb_security_group_id = var.docdb_security_group_id
}

# Compute (ECS + ALB) – uses outputs from VPC + IAM
module "compute" {
  source                 = "./modules/compute"
  ecs_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  db_secret_arn          = module.secrets.app_secrets_arn  
  app_secrets_arn        = module.secrets.app_secrets_arn
  log_group_name         = aws_cloudwatch_log_group.app.name  

  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_app_subnet_ids = module.vpc.private_app_subnet_ids

  account_id  = var.account_id
  region      = var.region
  kms_key_arn = aws_kms_key.cmk.arn

  alb_security_group_id = module.vpc.alb_sg_id
  app_security_group_id = module.vpc.app_sg_id
}

# Database – uses VPC private DB subnets with cost optimization
module "database" {
  source                = "./modules/database"
  db_username           = "wellness_user"
  db_password           = "R7Zsu43mmVPP3Vx3"
  kms_key_id            = aws_kms_key.cmk.arn
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  instance_count        = 1  # Start with 1 for cost savings
  vpc_id                = module.vpc.vpc_id
  app_security_group_id = module.vpc.app_sg_id
}

# Generate secure JWT secret
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

module "secrets" {
  source = "./modules/secrets"
  
  app_name            = "hipaa-app"
  account_id          = var.account_id
  documentdb_endpoint = "hipaa-docdb-cluster.cluster-coxso440o22q.us-east-1.docdb.amazonaws.com:27017"
  documentdb_username = "wellness_user"
  documentdb_password = "R7Zsu43mmVPP3Vx3"
  documentdb_database = "1wellness"
  
  jwt_secret          = random_password.jwt_secret.result
  
  depends_on = [module.database]

  # URLs
  client_url          = "https://d2r92yiqcdt8zm.cloudfront.net"
  base_url            = "https://dilnj1q0848o7.cloudfront.net/api"
  
  # SMTP
  smtp_email          = "expertweb634@gmail.com"
  smtp_password       = "exeo qgdg ecdz rsjd"
  smtp_host           = "smtp.gmail.com"
  smtp_port           = "587"
  
  # S3 
  s3_bucket_name = "1wellness-data"
  s3_region      = "us-east-1"
  
  # Email
  email_from          = "noreply@1wellness.com"
  admin_mail_from     = "webexpert@yopmail.com"
  admin_support_mail  = "webexpert@yopmail.com"
  admin_email         = "admin@1wellness.com"
  order_confirm_mail_from   = "orders@1wellness.com"
  
}

# ADD this to your root main.tf (after database/secrets modules):
module "s3" {
  source = "./modules/s3"
  
  data_bucket_name = "1wellness-data"   
  logs_bucket_name = "1wellness-logs"      
  
  kms_s3_data_arn = aws_kms_key.cmk.arn # Your existing KMS key
  kms_logs_arn    = aws_kms_key.cmk.arn # Same KMS key for logs
  
  app_name = "hipaa-app"
  
  depends_on = [aws_kms_key.cmk]
}

# CloudFront for Frontend Only
module "cloudfront" {
  source = "./modules/cloudfront"
  
  alb_dns_name           = module.compute.alb_dns_name
  alb_security_group_id = module.vpc.alb_sg_id
  
  depends_on = [module.compute]
}

# Backend CloudFront for API only
module "cloudfront_backend" {
  source = "./modules/cloudfront-backend"
  
  alb_dns_name           = module.compute.alb_dns_name
  alb_security_group_id = module.vpc.alb_sg_id
  
  depends_on = [module.compute]
}

# Cost Monitoring and Optimization
module "monitoring" {
  source = "./modules/monitoring"
  
  app_name    = "hipaa-app"
  region      = var.region
  kms_logs_arn = aws_kms_key.cmk.arn
  
  depends_on = [module.compute, module.database]
}
