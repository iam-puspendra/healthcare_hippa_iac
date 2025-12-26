variable "logs_bucket_name" {}
variable "kms_logs_arn" {}

resource "aws_cloudtrail" "this" {
  name                          = "med-hipaa-trail"
  s3_bucket_name                = var.logs_bucket_name
  is_multi_region_trail         = true
  include_global_service_events = true

  kms_key_id = var.kms_logs_arn
}

resource "aws_config_configuration_recorder" "this" {
  name     = "med-hipaa-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "med-hipaa-channel"
  s3_bucket_name = var.logs_bucket_name
}

resource "aws_guardduty_detector" "this" {
  enable = true
}

