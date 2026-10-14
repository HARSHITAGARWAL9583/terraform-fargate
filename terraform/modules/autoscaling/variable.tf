variable "project_name" {
  description = "Project name"
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

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 3
}

variable "cpu_target_value" {
  description = "Target average CPU utilization percentage for scaling"
  type        = number
  default     = 60
}
