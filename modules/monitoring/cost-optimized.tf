# Cost-Optimized Monitoring Configuration

# 1. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "hipaa-app-logs"
  retention_in_days = 90
  kms_key_id        = var.kms_logs_arn != "" ? var.kms_logs_arn : null
  
  tags = {
    Name = "hipaa-app-logs"
  }
}

# 2. Cost-Effective CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "hipaa-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ecs cpu utilization for cost optimization"

  dimensions = {
    ServiceName = "backend-service"
    ClusterName = "hipaa-ecs-cluster"
  }

  tags = {
    Name = "hipaa-backend-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_low" {
  alarm_name          = "hipaa-backend-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ecs cpu utilization for scale-in"

  dimensions = {
    ServiceName = "backend-service"
    ClusterName = "hipaa-ecs-cluster"
  }

  tags = {
    Name = "hipaa-backend-cpu-low-alarm"
  }
}

# 3. DocumentDB Cost Monitoring
resource "aws_cloudwatch_metric_alarm" "docdb_cpu_high" {
  alarm_name          = "hipaa-docdb-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "DocumentDB CPU utilization too high"

  dimensions = {
    DBClusterIdentifier = "hipaa-docdb-cluster"
  }

  alarm_actions = [aws_sns_topic.cost_alerts.arn]
  ok_actions    = [aws_sns_topic.cost_alerts.arn]

  tags = {
    Name = "hipaa-docdb-cpu-alarm"
  }
}

# 4. Cost Budget Alerts
resource "aws_budgets_budget" "monthly_budget" {
  name              = "hipaa-monthly-budget"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "500"
  limit_unit        = "USD"
  
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold_type             = "PERCENTAGE"
    threshold                  = 80
    subscriber_email_addresses = ["admin@1wellness.com"]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold_type             = "PERCENTAGE"
    threshold                  = 100
    subscriber_email_addresses = ["admin@1wellness.com"]
  }
}

# 5. SNS Topic for Alerts
resource "aws_sns_topic" "cost_alerts" {
  name = "hipaa-cost-alerts"
  
  tags = {
    Name = "hipaa-cost-alerts"
  }
}

# 6. CloudWatch Dashboard for Cost Monitoring
resource "aws_cloudwatch_dashboard" "hipaa_dashboard" {
  dashboard_name = "hipaa-cost-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "backend-service"],
            [".", ".", ".", "frontend-service"]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DocDB", "CPUUtilization", "DBClusterIdentifier", "hipaa-docdb-cluster"],
            [".", "DatabaseConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "DocumentDB Metrics"
        }
      }
    ]
  })
}
