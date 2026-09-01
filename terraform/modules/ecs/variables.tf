variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS networking"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "frontend_security_group_id" {
  description = "Security group ID for the frontend ECS service"
  type        = string
}

variable "backend_security_group_id" {
  description = "Security group ID for the backend ECS service"
  type        = string
}

variable "frontend_repository_url" {
  description = "Frontend ECR repository URL"
  type        = string
}

variable "backend_repository_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role"
  type        = string
}

variable "frontend_target_group_arn" {
  description = "ARN of the frontend ALB target group"
  type        = string
}

variable "backend_target_group_arn" {
  description = "ARN of the backend ALB target group"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 3
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarm notifications"
  type        = string
}
