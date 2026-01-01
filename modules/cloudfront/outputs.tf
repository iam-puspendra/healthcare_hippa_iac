# CloudFront Module Outputs

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.hipaa_cdn.domain_name
  description = "CloudFront distribution domain name (HTTPS enabled)"
}
