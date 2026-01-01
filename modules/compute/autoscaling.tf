# Auto-Scaling ECS Configuration

# 1. Application Auto Scaling for ECS Services
resource "aws_appautoscaling_target" "backend_target" {
  max_capacity       = 10
  min_capacity       = 1  # Start with 1 task for cost savings
  resource_id        = "service/hipaa-ecs-cluster/backend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "frontend_target" {
  max_capacity       = 6
  min_capacity       = 1  # Start with 1 task for cost savings
  resource_id        = "service/hipaa-ecs-cluster/frontend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 2. Scale-out based on CPU utilization
resource "aws_appautoscaling_policy" "backend_scale_out" {
  name               = "backend-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0  # Scale out at 70% CPU
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "frontend_scale_out" {
  name               = "frontend-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0  # Scale out at 70% CPU
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# 4. Scale based on request count (better for web applications)
# resource "aws_appautoscaling_policy" "backend_request_scale" {
#   name               = "backend-request-scale"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.backend_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.backend_target.service_namespace
# 
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ALBRequestCountPerTarget"
#       resource_label         = "app/hipaa-alb/ec46abff2024428a"
#     }
#     target_value       = 1000  # Scale when each target handles 1000 requests
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 60
#   }
# }

# 5. Scheduled scaling for cost optimization (scale down during off hours)
resource "aws_appautoscaling_scheduled_action" "backend_scale_down_night" {
  name               = "backend-scale-down-night"
  service_namespace  = aws_appautoscaling_target.backend_target.service_namespace
  resource_id        = aws_appautoscaling_target.backend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
  
  schedule = "cron(0 2 * * ? *)"  # Every day at 2 AM UTC
  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }
}

resource "aws_appautoscaling_scheduled_action" "backend_scale_up_day" {
  name               = "backend-scale-up-day"
  service_namespace  = aws_appautoscaling_target.backend_target.service_namespace
  resource_id        = aws_appautoscaling_target.backend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
  
  schedule = "cron(0 8 * * ? *)"  # Every day at 8 AM UTC
  scalable_target_action {
    min_capacity = 2
    max_capacity = 6
  }
}
