# CloudFront Distribution for Frontend Only

resource "aws_cloudfront_distribution" "hipaa_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "HIPAA Frontend CDN"
  
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "hipaa-alb"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Frontend: Static SPA only
  default_cache_behavior {
    target_origin_id  = "hipaa-alb"
    allowed_methods   = ["GET", "HEAD", "OPTIONS"]
    cached_methods    = ["GET", "HEAD"]
    compress          = true
    
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl     = 0
    default_ttl = 3600   # Cache static assets 1hr
    max_ttl     = 86400
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
  
  # SPA error handling
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
  
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
  
  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/index.html"
    error_caching_min_ttl = 60
  }
  
  tags = {
    Name        = "hipaa-frontend-cloudfront"
    Environment = "production"
  }
}
