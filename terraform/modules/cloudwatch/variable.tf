variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "frontend_service_name" {
  description = "Frontend ECS service name"
  type        = string
}

variable "backend_service_name" {
  description = "Backend ECS service name"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN to send alarm notifications"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU percentage threshold for alarm"
  type        = number
  default     = 80
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate alarm"
  type        = number
  default     = 2
}

variable "period" {
  description = "Period in seconds for metric evaluation"
  type        = number
  default     = 300
}
