variable "vpc_cidr" { // recivees 10.10...... okay
  description = "cidr block for the vpc"
  type        = string
}

variable "project_name" {
  description = "project name"
  type = string
}

variable "environment" {
  description = "Environmet name"
  type        = string
}



variable "availability_zones" {
  description = "Availability Zone for the VPC"
  type        = list(string)

}


variable "public_subnet_cidrs" {
  description = "CIDR block for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

}
