variable "vpc_id" {
  description = "VPC ID where the NAT instance will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the NAT instance"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
}
