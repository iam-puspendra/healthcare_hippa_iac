# =============================================================================
# OUTPUTS - Admin CloudFront Module
# =============================================================================

output "admin_cloudfront_domain_name" {
  description = "Domain name of the admin CloudFront distribution"
  value       = aws_cloudfront_distribution.hipaa_admin_cdn.domain_name
}

output "admin_cloudfront_distribution_id" {
  description = "ID of the admin CloudFront distribution"
  value       = aws_cloudfront_distribution.hipaa_admin_cdn.id
}

output "admin_cloudfront_status" {
  description = "Deployment status of the admin CloudFront distribution"
  value       = aws_cloudfront_distribution.hipaa_admin_cdn.status
}

output "admin_cloudfront_arn" {
  description = "ARN of the admin CloudFront distribution"
  value       = aws_cloudfront_distribution.hipaa_admin_cdn.arn
}
