variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (e.g. superarea.ai)"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names to include in the certificate (SANs)"
  type        = list(string)
  default     = []
}
