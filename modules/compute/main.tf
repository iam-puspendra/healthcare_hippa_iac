# Combined Cost-Optimized Compute Module

# ECS Cluster
resource "aws_ecs_cluster" "app" {
  name = "hipaa-ecs-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name = "hipaa-ecs-cluster"
  }
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "hipaa" {
  name        = "hipaa.local"
  description = "HIPAA application service discovery"
  vpc         = var.vpc_id
  
  tags = {
    Name = "hipaa-service-discovery"
  }
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"
  
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.hipaa.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

# ALB - Frontend Only
resource "aws_lb" "alb" {
  name               = "hipaa-alb"
  internal           = false     # Internet-facing for CloudFront
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids  # PUBLIC subnets for CloudFront
  
  enable_deletion_protection = false
  
  tags = {
    Name = "hipaa-alb"
  }
}

# ALB - Backend Only
resource "aws_lb" "backend_alb" {
  name               = "hipaa-backend-alb"
  internal           = false     # Internet-facing for CloudFront
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids  # PUBLIC subnets for CloudFront
  
  enable_deletion_protection = false
  
  tags = {
    Name = "hipaa-backend-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "frontend" {
  name     = "hipaa-frontend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  # Required for awsvpc network mode
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port               = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
  
  tags = {
    Name = "hipaa-frontend-tg"
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "hipaa-backend-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  # Required for awsvpc network mode
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"  # Accept 404 as valid
    path                = "/health"
    port               = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
  
  tags = {
    Name = "hipaa-backend-tg"
  }
}

# Frontend ALB Listener
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Backend ALB Listener
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# HTTP Listener for CloudFront
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
# RULE 1: API → Backend (Priority 10)
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 10
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# RULE 2: Frontend → Frontend (Priority 20)
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 20
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# Cost-Optimized Task Definitions
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = 512  # Reduced from 1024
  memory                   = 1024  # Reduced from 2048
  
  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/backend:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 3001
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "LOG_LEVEL"
          value = "warn"
        }
      ]
      
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${var.app_secrets_arn}:DB_HOST::"
        },
        {
          name      = "DB_USERNAME"
          valueFrom = "${var.app_secrets_arn}:DB_USERNAME::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.app_secrets_arn}:DB_PASSWORD::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.app_secrets_arn}:DB_NAME::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "${var.app_secrets_arn}:JWT_SECRET::"
        },
        {
          name      = "BASE_URL"
          valueFrom = "${var.app_secrets_arn}:BASE_URL::"
        },
        {
          name      = "CLIENT_URL"
          valueFrom = "${var.app_secrets_arn}:CLIENT_URL::"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend"
        }
      }
      
      # healthCheck = {
#         command     = ["CMD-SHELL", "curl -f http://localhost:3001/api/health || exit 1"]
#         interval    = 60
#         timeout     = 10
#         retries     = 5
#         startPeriod = 120
#       }
    }
  ])
  
  tags = {
    Name = "hipaa-backend-task"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = 256  # Minimum viable
  memory                   = 512  # Minimum viable
  
  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/frontend:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
  
  tags = {
    Name = "hipaa-frontend-task"
  }
}

# ECS Services with Auto-Scaling
resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1  # Start with 1 for cost savings
  launch_type     = "FARGATE"
  enable_execute_command = true
  
  network_configuration {
    subnets          = var.private_app_subnet_ids  # PRIVATE
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false                  # No public IP
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 3001
  }
  
  depends_on = [aws_lb_listener.backend]
  
  tags = {
    Name = "hipaa-backend-service"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1  # Start with 1 for cost savings
  launch_type     = "FARGATE"
  enable_execute_command = true
  
  network_configuration {
    subnets          = var.private_app_subnet_ids  # PRIVATE
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false                  # No public IP
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }
  
  depends_on = [aws_lb_listener.frontend]
  
  tags = {
    Name = "hipaa-frontend-service"
  }
}
