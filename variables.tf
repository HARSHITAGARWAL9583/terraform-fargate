variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Deployment environment (e.g. terraform-dev, staging, prod)"
  type        = string
  default     = "terraform-dev"
}

variable "notification_email" {
  description = "Email address to receive CloudWatch alarm / SNS notifications"
  type        = string
  default     = "harshit.a@moondviec.co"
}
