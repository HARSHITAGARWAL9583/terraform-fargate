output "frontend_target_id" {
  description = "Auto-scaling target ID for frontend"
  value       = aws_appautoscaling_target.frontend.id
}

output "frontend_policy_arn" {
  description = "Auto-scaling policy ARN for frontend"
  value       = aws_appautoscaling_policy.frontend_cpu.arn
}

output "backend_target_id" {
  description = "Auto-scaling target ID for backend"
  value       = aws_appautoscaling_target.backend.id
}

output "backend_policy_arn" {
  description = "Auto-scaling policy ARN for backend"
  value       = aws_appautoscaling_policy.backend_cpu.arn
}
