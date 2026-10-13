# Requirements: AWS ECS Fargate Infrastructure

## Introduction

This document defines the requirements for deploying a containerized application on AWS using Terraform. The infrastructure supports a frontend (React/nginx) and backend (Node.js) application running on ECS Fargate, accessible via an Application Load Balancer.

---

## Glossary

| Term | Definition |
|------|------------|
| ECS | Elastic Container Service — AWS managed container orchestration |
| Fargate | Serverless compute engine for containers (no EC2 management) |
| ECR | Elastic Container Registry — AWS Docker image storage |
| ALB | Application Load Balancer — routes HTTP traffic to containers |
| NAT Gateway | Allows private subnet resources to reach the internet |
| Task Definition | Blueprint for running a container in ECS |
| Target Group | ALB component that routes traffic to specific containers |

---

## Requirements

### Requirement 1: Network Isolation

**User Story:** As a DevOps engineer, I want the application containers to run in private subnets, so that they are not directly accessible from the internet.

#### Acceptance Criteria

1. WHEN the infrastructure is deployed, THEN a VPC SHALL be created with both public and private subnets across at least 2 availability zones.
2. WHEN ECS tasks are launched, THEN they SHALL be placed in private subnets with `assign_public_ip = false`.
3. WHEN private subnet resources need internet access, THEN all outbound traffic SHALL route through an AWS Managed NAT Gateway.
4. IF the NAT Gateway is unavailable, THEN ECS tasks SHALL fail to pull images from ECR with a clear error message.

---

### Requirement 2: Container Image Management

**User Story:** As a developer, I want to store Docker images in a private registry, so that ECS can securely pull them during deployment.

#### Acceptance Criteria

1. WHEN the infrastructure is provisioned, THEN ECR repositories SHALL be created for both frontend and backend services.
2. WHEN a new image is pushed to ECR with the `latest` tag, THEN the ECS service SHALL pull the updated image on the next deployment.
3. WHEN ECS pulls an image, THEN the task execution role SHALL have `AmazonECSTaskExecutionRolePolicy` attached.
4. IF the ECR endpoint is unreachable, THEN ECS SHALL report a `ResourceInitializationError` with the specific connection error.

---

### Requirement 3: Load Balancing and Traffic Routing

**User Story:** As a user, I want all application traffic to go through a single URL, so that I don't need to know the internal container addresses.

#### Acceptance Criteria

1. WHEN a request hits the ALB on port 80, THEN it SHALL be forwarded to the frontend target group by default.
2. WHEN a request path matches `/api/*`, THEN it SHALL be forwarded to the backend target group instead.
3. WHEN the frontend container is healthy, THEN the ALB health check SHALL pass against `GET /` on port 80.
4. WHEN the backend container is healthy, THEN the ALB health check SHALL pass against `GET /health` on port 5000.
5. IF no healthy targets exist, THEN the ALB SHALL return `503 Service Unavailable`.

---

### Requirement 4: Auto Scaling

**User Story:** As a DevOps engineer, I want the application to scale automatically based on CPU usage, so that performance is maintained under load.

#### Acceptance Criteria

1. WHEN CPU utilization exceeds 60% for 2 consecutive periods of 5 minutes, THEN ECS SHALL scale out by adding tasks.
2. WHEN CPU utilization drops below the threshold, THEN ECS SHALL scale in to the minimum capacity.
3. THE minimum task count SHALL be 1 and maximum SHALL be 3 for both services.

---

### Requirement 5: Monitoring and Alerting

**User Story:** As a DevOps engineer, I want to receive alerts when CPU usage is high, so that I can investigate before users are impacted.

#### Acceptance Criteria

1. WHEN CPU utilization exceeds 80% for 2 evaluation periods, THEN a CloudWatch alarm SHALL trigger.
2. WHEN an alarm triggers, THEN a notification SHALL be sent to the configured email via SNS.
3. WHEN the infrastructure is deployed, THEN CloudWatch log groups SHALL be created for both frontend and backend containers with 30-day retention.
