# Produce outputs which can be consumed by other resources

# Outputs the Host Endpoint of the created RDS instance
output "db_host" {
  description = "The host endpoint for the RDS instance"
  value       = aws_db_instance.default.endpoint    # The actual host endpoint of the RDS instance
}

# Outputs the name of the created RDS instance
output "db_name" {
  description = "The name for the RDS instance"
  value       = aws_db_instance.default.db_name    # The actual name of the RDS instance
}