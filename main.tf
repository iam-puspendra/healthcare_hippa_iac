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

# Define VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "hipaa-vpc"
  }
}

# Define public subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = "us-east-1${element(["a", "b"], count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${count.index}"
  }
}

# Define private app subnets
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = "us-east-1${element(["a", "b"], count.index)}"
  tags = {
    Name = "private-app-${count.index}"
  }
}

# Define private db subnets
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 5}.0/24"
  availability_zone = "us-east-1${element(["a", "b"], count.index)}"
  tags = {
    Name = "private-db-${count.index}"
  }
}

# Define KMS key
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


# Define security group for ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define CloudWatch log group
resource "aws_cloudwatch_log_group" "app" {
  name              = "hipaa-app-logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cmk.arn
}

# Call modules
module "iam" {
  source        = "./modules/iam"
  kms_key_arn   = aws_kms_key.cmk.arn
  log_group_arn = aws_cloudwatch_log_group.app.arn
}

module "compute" {
  source                 = "./modules/compute"
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  private_app_subnet_ids = aws_subnet.private_app[*].id
  public_subnet_ids      = aws_subnet.public[*].id
  vpc_id                 = aws_vpc.main.id
  region                 = "us-east-1"
  kms_key_arn            = aws_kms_key.cmk.arn
  alb_security_group_id  = aws_security_group.alb.id
  app_security_group_id  = aws_security_group.app.id
}

module "database" {
  source                = "./modules/database"
  db_username           = "medadmin"
  db_password           = "secH1ppP55wD"
  kms_key_id            = aws_kms_key.cmk.arn
  private_db_subnet_ids = aws_subnet.private_db[*].id
  instance_count        = 1
}
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}