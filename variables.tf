variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "superarea"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "notification_email" {
  description = "Email address to receive CloudWatch alarm / SNS notifications"
  type        = string
  default     = "admin@superarea.ai"
}

variable "domain_name" {
  description = "Primary domain name for ACM SSL certificate"
  type        = string
  default     = "superarea.ai"
}
