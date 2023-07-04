# Produce outputs which can be consumed by other resources

# Output the username for the database from the AWS Systems Manager Parameter Store
# Storing sensitive data like secrets in SSM Parameter Store and Secrets Manager provides an additional layer of security.
output "db_username" {
  description = "Database username retrieved from AWS SSM Parameter Store"
  value       = aws_ssm_parameter.db_username.value
  sensitive   = true # It hides the output from CLI, reducing the exposure of sensitive information.
}

# Output the password for the database from the AWS Systems Manager Parameter Store
output "db_password" {
  description = "Database password retrieved from AWS SSM Parameter Store"
  value       = aws_ssm_parameter.db_password.value
  sensitive   = true # It hides the output from CLI, reducing the exposure of sensitive information.
}

# Output the AWS Secrets Manager's secret name
# Secrets Manager is used to rotate, manage, and retrieve database credentials, API keys, and other secrets throughout their lifecycle.
output "secret_manager_name" {
  description = "Name of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.wordpress.name
  sensitive   = true # It hides the output from CLI, reducing the exposure of sensitive information.
}

# Output the ARN(Amazon Resource Number) of the AWS Secrets Manager's secret
output "ssm_arn_id" {
  description = "ARN of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.wordpress.arn
}