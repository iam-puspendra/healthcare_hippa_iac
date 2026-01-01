output "backend_cloudfront_domain" {
  value = aws_cloudfront_distribution.hipaa_backend_cdn.domain_name
}

output "backend_cloudfront_id" {
  value = aws_cloudfront_distribution.hipaa_backend_cdn.id
}
