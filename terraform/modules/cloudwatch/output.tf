output "frontend_cpu_alarm_arn" {
  description = "ARN of frontend CPU high alarm"
  value       = aws_cloudwatch_metric_alarm.frontend_cpu_high.arn
}

output "backend_cpu_alarm_arn" {
  description = "ARN of backend CPU high alarm"
  value       = aws_cloudwatch_metric_alarm.backend_cpu_high.arn
}
