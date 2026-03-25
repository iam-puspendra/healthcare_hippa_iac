# Admin Service Module

## Overview
This module creates a complete ECS Fargate service for the admin application with auto-scaling, security, and observability.

## Architecture
- **Compute**: ECS Fargate with 512 CPU units and 1GB RAM
- **Networking**: Private subnets with dedicated security group
- **Load Balancing**: ALB target group with path-based routing (/admin*)
- **Auto-Scaling**: Scale between 1-3 replicas based on 70% CPU
- **Logging**: CloudWatch Logs with 7-day retention
- **Security**: IAM roles with least privilege access
- **Service Discovery**: Optional AWS Cloud Map integration

## Resources Created
- ECS Task Definition (admin-task)
- Security Group (hipaa-admin-sg)
- Target Group (hipaa-admin-tg)
- ALB Listener Rule (/admin* → admin target group)
- ECS Service (admin-service)
- Auto-Scaling Target & Policy
- CloudWatch Log Group (optional)
- Service Discovery Service (optional)

## Usage
```hcl
module "admin_service" {
  source = "./modules/admin-service"
  
  # Required
  environment               = "production"
  account_id               = var.account_id
  ecs_cluster_name         = "hipaa-ecs-cluster"
  ecs_execution_role_arn    = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn         = module.iam.ecs_task_role_arn
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_app_subnet_ids
  alb_security_group_id     = module.vpc.alb_sg_id
  alb_listener_arn         = aws_lb_listener.main.arn
  app_secrets_arn          = module.secrets.app_secrets_arn
  
  # Optional
  image_tag                = "v1.0.0"
  enable_service_discovery  = true
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.hipaa.id
  create_log_group         = true
}
```

## Security Considerations
- Tasks run in private subnets with no public IPs
- Security group only allows traffic from ALB
- Secrets are retrieved from AWS Secrets Manager
- IAM roles follow least privilege principle
- Health checks enabled for container and target group

## Auto-Scaling Behavior
- **Scale Out**: When CPU > 70% for 1 minute
- **Scale In**: When CPU < 70% for 5 minutes
- **Min/Max**: 1-3 replicas
- **Cooldown**: Prevents rapid scaling oscillations

## Monitoring
- Container health checks via HTTP /health endpoint
- Target group health checks with 200-399 response codes
- CloudWatch logs with structured logging
- Auto-scaling metrics and alarms

## Service Discovery
When enabled, the admin service registers with AWS Cloud Map for internal service-to-service communication using the service name `admin.hipaa.local`.
