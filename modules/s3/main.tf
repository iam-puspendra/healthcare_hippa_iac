# Cost-Optimized S3 Configuration

# 1. Data Bucket with Lifecycle Policies (use existing)
resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.data_bucket_name}-optimized"  # Different name to avoid conflict
  
  tags = {
    Name        = "hipaa-data-bucket-optimized"
    Environment = "production"
  }
}

# 2. Enable versioning for data integrity
resource "aws_s3_bucket_versioning" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = var.kms_s3_data_arn
    }
    bucket_key_enabled = true
  }
}

# 4. Block public access for HIPAA compliance
resource "aws_s3_bucket_public_access_block" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Lifecycle Policy for Cost Optimization
resource "aws_s3_bucket_lifecycle_configuration" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    id     = "lifecycle_policy"
    status = "Enabled"
    
    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    # Transition to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    # Transition to Deep Archive after 365 days
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
    
    # Delete old versions after 7 years
    noncurrent_version_expiration {
      noncurrent_days = 2555  # 7 years
    }
    
    # Abort incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# 6. Logs Bucket with Cost Optimization (use existing)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.logs_bucket_name}-optimized"  # Different name to avoid conflict
  
  tags = {
    Name        = "hipaa-logs-bucket-optimized"
    Environment = "production"
  }
}

# 7. Logs bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = var.kms_logs_arn
    }
    bucket_key_enabled = true
  }
}

# 8. Logs bucket lifecycle (shorter retention for cost savings)
resource "aws_s3_bucket_lifecycle_configuration" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "logs_lifecycle"
    status = "Enabled"
    
    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    # Transition to Glacier after 60 days
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    
    # Delete logs after 90 days (HIPAA requirement)
    expiration {
      days = 90
    }
    
    # Abort incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
