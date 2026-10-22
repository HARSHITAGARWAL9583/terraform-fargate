# ─── Networking ───────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# ─── Load Balancer ────────────────────────────────────────────────────────────

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — use this to reach the app"
  value       = module.alb.alb_dns_name
}

# ─── Container Registry ───────────────────────────────────────────────────────

output "frontend_repository_url" {
  description = "ECR repository URL for the frontend image"
  value       = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  description = "ECR repository URL for the backend image"
  value       = module.ecr.backend_repository_url
}

# ─── ECS ──────────────────────────────────────────────────────────────────────

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

# ─── Monitoring ───────────────────────────────────────────────────────────────

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = module.sns.sns_topic_arn
}

# ─── SSL / ACM ────────────────────────────────────────────────────────────────

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.acm.certificate_arn
}

output "acm_dns_validation_records" {
  description = "CNAME records to add into Hostinger DNS for SSL validation"
  value       = module.acm.dns_validation_records
}

# ─── Remote State Storage ─────────────────────────────────────────────────────

output "state_s3_bucket" {
  description = "S3 bucket name storing Terraform state"
  value       = module.state_s3.bucket_name
}




