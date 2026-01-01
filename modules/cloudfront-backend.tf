# CloudFront Distribution for Backend API Only

resource "random_id" "backend_secret" {
  byte_length = 32
}

resource "aws_cloudfront_distribution" "hipaa_backend_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "HIPAA Backend API CDN"
  
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "hipaa-backend-alb"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Backend API: No caching, all methods
  default_cache_behavior {
    target_origin_id  = "hipaa-backend-alb"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }
    
    viewer_protocol_policy = "https-only"
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = false
  }
  
  price_class = "PriceClass_100"
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
  
  tags = {
    Name        = "hipaa-backend-cloudfront"
    Environment = "production"
  }
  
  depends_on = [random_id.backend_secret]
}

# Output backend CloudFront domain
output "backend_cloudfront_domain" {
  value = aws_cloudfront_distribution.hipaa_backend_cdn.domain_name
}

output "backend_cloudfront_id" {
  value = aws_cloudfront_distribution.hipaa_backend_cdn.id
}
