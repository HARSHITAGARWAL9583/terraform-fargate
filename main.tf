# terraform {
#   backend "s3" {
#     bucket  = "superarea-prod-state-s3"
#     key     = "prod/terraform.tfstate"
#     region  = "ap-south-1"
#     encrypt = true
#   }
# }


# ─── 1. Networking (VPC & NAT) ────────────────────────────────────────────────

module "vpc" {
  source       = "./terraform/modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"

  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "nat" {
  source = "./terraform/modules/nat"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  private_subnet_ids   = module.vpc.private_subnet_ids
  private_subnet_cidrs = module.vpc.private_subnet_cidrs
}

# ─── 2. Security & IAM ────────────────────────────────────────────────────────

module "security_groups" {
  source       = "./terraform/modules/security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source       = "./terraform/modules/iam"
  project_name = var.project_name
  environment  = var.environment
}

# ─── 3. Container Registry (ECR) ──────────────────────────────────────────────

module "ecr" {
  source       = "./terraform/modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

# ─── 4. Notifications & SSL Certificate ───────────────────────────────────────

module "sns" {
  source             = "./terraform/modules/sns"
  project_name       = var.project_name
  environment        = var.environment
  notification_email = var.notification_email
}

module "acm" {
  source                    = "./terraform/modules/acm"
  project_name              = var.project_name
  environment               = var.environment
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
}

# ─── 5. Load Balancer (ALB) ───────────────────────────────────────────────────

module "alb" {
  source            = "./terraform/modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
}

# ─── 6. ECS Fargate Cluster & Services ────────────────────────────────────────

module "ecs" {
  source       = "./terraform/modules/ecs"
  project_name = var.project_name
  environment  = var.environment

  # Networking
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security groups
  frontend_security_group_id = module.security_groups.frontend_security_group_id
  backend_security_group_id  = module.security_groups.backend_security_group_id

  # ECR image URLs
  frontend_repository_url = module.ecr.frontend_repository_url
  backend_repository_url  = module.ecr.backend_repository_url

  # IAM roles
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn

  # ALB target groups
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn
}

# ─── 7. Auto Scaling & Monitoring ─────────────────────────────────────────────

module "autoscaling" {
  source                = "./terraform/modules/autoscaling"
  project_name          = var.project_name
  environment           = var.environment
  ecs_cluster_name      = module.ecs.cluster_name
  frontend_service_name = module.ecs.frontend_service_name
  backend_service_name  = module.ecs.backend_service_name

  min_capacity = 1
  max_capacity = 3
}

module "cloudwatch" {
  source                = "./terraform/modules/cloudwatch"
  project_name          = var.project_name
  environment           = var.environment
  ecs_cluster_name      = module.ecs.cluster_name
  frontend_service_name = module.ecs.frontend_service_name
  backend_service_name  = module.ecs.backend_service_name
  sns_topic_arn         = module.sns.sns_topic_arn
}

# ─── 8. Remote State Storage (S3 & DynamoDB) ──────────────────────────────────

module "state_s3" {
  source       = "./terraform/modules/state-s3"
  project_name = var.project_name
  environment  = var.environment
}

