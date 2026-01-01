resource "aws_ecs_cluster" "app" {
  name = "hipaa-ecs-cluster"
  tags = {
    Name = "hipaa-ecs-cluster"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = 256
  memory                   = 512
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
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  enable_execute_command = true
  
  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }
}

resource "aws_lb" "app" {
  name                       = "hipaa-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = true
  tags = {
    Name = "hipaa-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn  
  }
}

#  BACKEND API - PRIORITY 10 (FIRST!)
resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.frontend.arn  
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/health"]  
    }
  }
}

#  FRONTEND - PRIORITY 20 (Static assets)
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.frontend.arn  
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {  # ← FIXED: path_pattern not host_header!
      values = ["/", "/static/*", "/favicon.ico"]
    }
  }
}

# --- BACKEND RESOURCES ---
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([{
    name      = "backend"
    image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/backend:latest"
    essential = true
    enable_execute_command = true

    portMappings = [{
      containerPort = 3001
      protocol      = "tcp"
    }]
    
    secrets = [
      {
        name      = "DB_SECRET_ARN"
        valueFrom = var.db_secret_arn
      },
      {
        name      = "APP_SECRETS_ARN"
        valueFrom = var.app_secrets_arn
      }
    ]
    
    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "AWS_REGION", value = var.region }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = "backend"
      }
    }
  }])
}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  enable_execute_command = true
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 3001
  }
}

resource "aws_lb_target_group" "backend" {
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id 
  target_type = "ip"       

  health_check {
    path                = "/health" 
    port                = "3001"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Create ECR for Backend
resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
