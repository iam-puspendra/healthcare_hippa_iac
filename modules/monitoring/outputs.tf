output "cost_dashboard_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=hipaa-cost-monitoring"
  description = "CloudWatch cost monitoring dashboard URL"
}

output "budget_arn" {
  value = aws_budgets_budget.monthly_budget.arn
  description = "AWS Budget ARN"
}
