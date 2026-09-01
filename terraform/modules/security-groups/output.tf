output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "frontend_security_group_id" {
  description = "Security group ID for the frontend ECS service"
  value       = aws_security_group.frontend.id
}

output "backend_security_group_id" {
  description = "Security group ID for the backend ECS service"
  value       = aws_security_group.backend.id
}
