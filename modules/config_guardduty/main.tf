terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# TODO: implement ${d} module
resource "aws_guardduty_detector" "this" {
  enable = true
}

# Optional: send findings to S3 bucket
resource "aws_guardduty_publishing_destination" "this" {
  detector_id      = aws_guardduty_detector.this.id
  destination_type = "S3"
  destination_arn  = "arn:aws:s3:::${var.logs_bucket_name}"
  kms_key_arn      = "arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:key/your-kms-key-id"
}

data "aws_caller_identity" "current" {}

