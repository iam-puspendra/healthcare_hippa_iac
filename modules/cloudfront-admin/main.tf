# =============================================================================
# CLOUDFRONT DISTRIBUTION - Admin Service
# =============================================================================

resource "random_id" "admin_secret" {
  byte_length = 32
}

resource "aws_cloudfront_distribution" "hipaa_admin_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "HIPAA Admin Service CDN"
  
  # Origin pointing to ALB
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "hipaa-admin-alb"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Default cache behavior - Admin routes
  default_cache_behavior {
    target_origin_id  = "hipaa-admin-alb"
    allowed_methods   = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods    = ["GET", "HEAD"]
    compress          = true
    
    forwarded_values {
      query_string = true
      cookies { 
        forward = "all" 
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl     = 0
    default_ttl = 3600  # Cache for 1 hour
    max_ttl     = 86400 # Cache for 24 hours
  }
  
  # Admin API - No caching for dynamic content
  ordered_cache_behavior {
    path_pattern     = "/admin/api/*"
    target_origin_id = "hipaa-admin-alb"
    
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = true
      cookies { 
        forward = "all" 
      }
    }
    
    viewer_protocol_policy = "https-only"
    min_ttl     = 0
    default_ttl = 0  # No caching for API calls
    max_ttl     = 0
    compress    = false
  }
  
  # Admin static assets - Aggressive caching
  ordered_cache_behavior {
    path_pattern     = "/admin/static/*"
    target_origin_id = "hipaa-admin-alb"
    
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress          = true
    
    forwarded_values {
      query_string = false
      cookies { 
        forward = "none" 
      }
    }
    
    viewer_protocol_policy = "https-only"
    min_ttl     = 86400  # Cache for 24 hours
    default_ttl = 604800 # Cache for 7 days
    max_ttl     = 31536000 # Cache for 1 year
  }
  
  # Price optimization
  price_class = "PriceClass_100"
  
  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # SSL/TLS configuration
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
  
  # Error handling for SPA
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/admin/index.html"
    error_caching_min_ttl = 300
  }
  
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/admin/index.html"
    error_caching_min_ttl = 300
  }
  
  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/admin/index.html"
    error_caching_min_ttl = 60
  }
  
  tags = {
    Name        = "hipaa-admin-cloudfront"
    Environment = var.environment
    Service    = "admin"
  }
  
  depends_on = [random_id.admin_secret]
}
