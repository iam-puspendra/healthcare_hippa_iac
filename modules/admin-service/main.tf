# =============================================================================
# TASK DEFINITION - Admin Service
# =============================================================================

resource "aws_ecs_task_definition" "admin" {
  family                   = "admin-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    {
      name      = "admin"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/admin:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 3002
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "PORT"
          value = "3002"
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
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "admin"
        }
      }
    }
  ])

  tags = {
    Name        = "admin-task"
    Environment = var.environment
  }
}

# =============================================================================
# ADMIN ALB - Dedicated Load Balancer for Admin Service
# =============================================================================

resource "aws_lb" "admin" {
  name               = "hipaa-admin-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "hipaa-admin-alb"
    Environment = var.environment
  }
}

# Admin ALB Listener
resource "aws_lb_listener" "admin" {
  load_balancer_arn = aws_lb.admin.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }

  tags = {
    Name        = "hipaa-admin-listener"
    Environment = var.environment
  }
}

# =============================================================================
# SECURITY GROUP - Admin Service
# =============================================================================

resource "aws_security_group" "admin" {
  name        = "hipaa-admin-sg"
  description = "Security group for admin service"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB to admin service"
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "hipaa-admin-sg"
    Environment = var.environment
  }
}

# =============================================================================
# TARGET GROUP - Admin Service
# =============================================================================

resource "aws_lb_target_group" "admin" {
  name        = "hipaa-admin-tg"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200-399"
    path                = "/"                # "/" works with serve -s dist
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "hipaa-admin-tg"
    Environment = var.environment
  }
}

# =============================================================================
# ECS SERVICE - Admin Service
# =============================================================================

resource "aws_ecs_service" "admin" {
  name            = "admin-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.admin.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.admin.arn
    container_name   = "admin"
    container_port   = 3002
  }

  depends_on = [aws_lb_listener.admin]

  tags = {
    Name        = "hipaa-admin-service"
    Environment = var.environment
  }
}

# =============================================================================
# AUTO-SCALING - Admin Service
# =============================================================================

resource "aws_appautoscaling_target" "admin" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.admin.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "admin_scale_out" {
  name               = "hipaa-admin-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.admin.resource_id
  scalable_dimension = aws_appautoscaling_target.admin.scalable_dimension
  service_namespace  = aws_appautoscaling_target.admin.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# =============================================================================
# SERVICE DISCOVERY - Optional
# =============================================================================

resource "aws_service_discovery_service" "admin" {
  count = var.enable_service_discovery ? 1 : 0

  name = "admin"

  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  depends_on = [aws_ecs_service.admin]
}

# =============================================================================
# CLOUDWATCH LOG GROUP - Admin Service Logs
# =============================================================================

resource "aws_cloudwatch_log_group" "admin" {
  count = var.create_log_group ? 1 : 0

  name              = var.log_group_name   # "hipaa-admin-logs" or similar
  retention_in_days = 7

  tags = {
    Name        = "hipaa-admin-logs"
    Environment = var.environment
  }
}
