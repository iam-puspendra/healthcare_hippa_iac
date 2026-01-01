output "data_bucket_name" {
  value = aws_s3_bucket.data_bucket.id
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.id
}

output "data_bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs_bucket.arn
}
