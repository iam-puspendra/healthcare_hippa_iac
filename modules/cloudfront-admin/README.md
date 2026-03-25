# Admin CloudFront Module

## Overview
This module creates a dedicated CloudFront distribution for the admin service with optimized caching strategies for different content types.

## Architecture
- **Default Behavior**: Admin routes with standard caching (1 hour)
- **API Routes**: `/admin/api/*` with no caching for dynamic content
- **Static Assets**: `/admin/static/*` with aggressive caching (7 days)
- **Security**: HTTPS-only with modern TLS protocols
- **Error Handling**: SPA-friendly error responses

## Cache Strategy

### Admin Routes (`/admin/*`)
- **TTL**: 1 hour default, 24 hours max
- **Methods**: All HTTP methods supported
- **Cookies**: Forward all for session management
- **Compression**: Enabled for performance

### Admin API (`/admin/api/*`)
- **TTL**: No caching (0 TTL) for real-time data
- **Methods**: All HTTP methods for full API support
- **Cookies**: Forward all for authentication
- **Compression**: Disabled for API consistency

### Static Assets (`/admin/static/*`)
- **TTL**: 7 days default, 1 year max
- **Methods**: GET/HEAD only (read-only)
- **Cookies**: None forwarded for cache efficiency
- **Compression**: Enabled for bandwidth savings

## Usage
```hcl
module "admin_cloudfront" {
  source = "./modules/cloudfront-admin"
  
  alb_dns_name           = module.compute.alb_dns_name
  alb_security_group_id = module.vpc.alb_sg_id
  environment            = "production"
}
```

## Features

### Security
- HTTPS-only access with automatic HTTP to HTTPS redirect
- TLS 1.2_2021 minimum protocol version
- SNI-only SSL support for compatibility
- Geographic restrictions (configurable)

### Performance
- Price Class 100 for cost optimization
- Multiple cache behaviors for optimal performance
- Gzip compression enabled where appropriate
- Edge location optimization

### Reliability
- SPA-friendly error handling (404 → 200)
- Custom error pages for better UX
- Health check integration with ALB
- Automatic failover support

## Integration Notes

### ALB Integration
The module expects the ALB to have proper listener rules:
- `/admin*` routes to admin target group (port 3002)
- Health checks on `/admin/health` endpoint

### Cache Invalidation
Deployments should invalidate cache using:
```bash
# Invalidate all admin content
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/admin/*"

# Invalidate only API cache
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/admin/api/*"
```

### Monitoring
Enable CloudFront metrics for:
- Cache hit/miss ratios
- Error rates (4xx, 5xx)
- Latency measurements
- Data transfer costs

## Security Considerations

- Origin access restricted to ALB security group
- No direct origin access from internet
- WAF integration recommended for production
- Regular certificate rotation for custom domains
