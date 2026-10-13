# Design: AWS ECS Fargate Infrastructure

## Overview

This document describes the technical design for the AWS ECS Fargate infrastructure provisioned via Terraform. The system runs two containerized services (frontend and backend) in private subnets behind an Application Load Balancer.

---

## High-Level Architecture

```
                        Internet
                            │
                     ┌──────▼──────┐
                     │     ALB     │  (Public Subnets)
                     │  port 80    │
                     └──────┬──────┘
                            │
              ┌─────────────┴─────────────┐
              │ /*                        │ /api/*
              ▼                           ▼
   ┌──────────────────┐       ┌──────────────────┐
   │ Frontend Service │       │ Backend Service  │
   │ nginx : port 80  │       │ node  : port 5000│
   │ (Private Subnet) │       │ (Private Subnet) │
   └────────┬─────────┘       └────────┬─────────┘
            │                          │
            └──────────┬───────────────┘
                       ▼
               ┌──────────────┐
               │ NAT Gateway  │  (Public Subnet)
               └──────┬───────┘
                      ▼
                  Internet
               (ECR, CloudWatch)
```

---

## Module Design

### 1. VPC Module (`terraform/modules/vpc`)

| Resource | Config |
|----------|--------|
| VPC | CIDR: `10.10.0.0/16` |
| Public Subnets | `10.10.1.0/24`, `10.10.2.0/24` (ap-south-1a, 1b) |
| Private Subnets | `10.10.3.0/24`, `10.10.4.0/24` (ap-south-1a, 1b) |
| Internet Gateway | Attached to VPC |
| Public Route Table | `0.0.0.0/0` → IGW |

**Key decisions:**
- Public subnets have `map_public_ip_on_launch = true` for ALB
- Private subnets have no direct internet route (handled by NAT module)

---

### 2. NAT Module (`terraform/modules/nat`)

| Resource | Config |
|----------|--------|
| Elastic IP | Allocated for NAT Gateway |
| NAT Gateway | Placed in `public_subnet[0]` |
| Private Route Table | `0.0.0.0/0` → NAT Gateway |

**Key decisions:**
- Uses **AWS Managed NAT Gateway** (not EC2 NAT instance) for reliability
- Single NAT Gateway in one AZ (cost optimized for dev)
- Route table associated with both private subnets

---

### 3. Security Groups Module (`terraform/modules/security-groups`)

| Group | Inbound | Outbound |
|-------|---------|----------|
| `alb-sg` | 80 from `0.0.0.0/0` | All |
| `frontend-sg` | 80 from `alb-sg` | All |
| `backend-sg` | 5000 from `alb-sg`, 5000 from `frontend-sg` | All |

---

### 4. ECR Module (`terraform/modules/ecr`)

- Two repositories: `myapp-<env>-frontend`, `myapp-<env>-backend`
- Images tagged as `:latest`
- ECS pulls on service deployment

---

### 5. IAM Module (`terraform/modules/iam`)

| Role | Policy |
|------|--------|
| `ecs-task-execution-role` | `AmazonECSTaskExecutionRolePolicy` |
| `ecs-task-role` | Custom (for app-level AWS access) |

---

### 6. ALB Module (`terraform/modules/alb`)

| Resource | Config |
|----------|--------|
| ALB | Internet-facing, public subnets |
| Frontend Target Group | Port 80, health check `GET /` |
| Backend Target Group | Port 5000, health check `GET /health` |
| Listener | Port 80 → frontend TG (default) |
| Listener Rule | `/api/*` → backend TG (priority 100) |

---

### 7. ECS Module (`terraform/modules/ecs`)

**Task Definitions:**

| Service | CPU | Memory | Port | Image |
|---------|-----|--------|------|-------|
| Frontend | 256 | 512 MB | 80 | ECR frontend:latest |
| Backend | 256 | 512 MB | 5000 | ECR backend:latest |

**Services:**
- Launch type: `FARGATE`
- Network: private subnets, no public IP
- Desired count: 1
- Auto-scaling: min 1, max 3, target CPU 60%

---

### 8. Monitoring Module (`terraform/modules/monitoring`)

| Resource | Config |
|----------|--------|
| SNS Topic | Email subscription for alerts |
| CloudWatch Alarm (frontend) | CPU > 80% for 2 × 5min periods |
| CloudWatch Alarm (backend) | CPU > 80% for 2 × 5min periods |
| Log Groups | `/ecs/myapp/<env>/frontend`, `/ecs/myapp/<env>/backend` — 30 day retention |

---

## Deployment Flow

```
Developer
    │
    ├─ docker build + push → ECR
    │
    └─ terraform apply
              │
              ├─ VPC + Subnets
              ├─ NAT Gateway
              ├─ Security Groups
              ├─ IAM Roles
              ├─ ECR Repos
              ├─ ALB + Target Groups
              ├─ ECS Cluster + Task Definitions
              ├─ ECS Services (pulls from ECR via NAT)
              └─ CloudWatch + SNS
```

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Managed NAT Gateway over EC2 NAT | EC2 NAT requires manual iptables setup which is unreliable on AL2023 |
| ECS Fargate over EC2 | No server management, scales per task |
| Private subnets for ECS | Security — containers not directly exposed |
| ALB path-based routing | Single URL for both frontend and backend |
| `name_prefix` on target groups | Allows `create_before_destroy` without naming conflicts |

---

## Ports Reference

| Service | Container Port | Protocol |
|---------|---------------|----------|
| Frontend (nginx) | 80 | HTTP |
| Backend (Node.js) | 5000 | HTTP |
| ALB Listener | 80 | HTTP |
