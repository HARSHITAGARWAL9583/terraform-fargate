output "nat_instance_id" {
  description = "ID of the NAT EC2 instance"
  value       = aws_instance.nat.id
}

output "nat_public_ip" {
  description = "Elastic IP allocated for the NAT instance"
  value       = aws_eip.nat.public_ip
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
