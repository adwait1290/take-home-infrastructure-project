# Produce outputs which can be consumed by other resources

# Outputting the ID of the VPC - Useful if the VPC needs to be referenced in other Terraform scripts or manually
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Outputting the ID of the VPC - Useful if the VPC needs to be referenced in other Terraform scripts or manually
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public.*.id
}

# Outputting the ID of the VPC - Useful if the VPC needs to be referenced in other Terraform scripts or manually
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private.*.id
}