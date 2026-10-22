resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-frontend-cpu-high"
  alarm_description   = "Frontend ECS service CPU is high"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.frontend_service_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend-cpu-alarm"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-backend-cpu-high"
  alarm_description   = "Backend ECS service CPU is high"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.backend_service_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-cpu-alarm"
    Environment = var.environment
  }
}
