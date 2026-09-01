// result bahar jaata hai doosre modules use karne ka liya 

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id // vpc-hubne3k4i3 //back to root main.tf
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}