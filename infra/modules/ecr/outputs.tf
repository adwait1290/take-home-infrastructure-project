# Produce outputs which can be consumed by other resources
# In this case, it helps provide information about the created ECR repository

# Capture the URL of the created ECR repository in an output variable
output "repository_url" {
  description = "The URL of the repository"
  # Get the ECR repository URL from the terraform state
  value       = aws_ecr_repository.repository.repository_url
}

# Capture the ID of the created ECR repository in an output variable
output "repository_id" {
  description = "The ID of the repository"
  # Get the ECR repository ID from the Terraform state.
  # This could be useful to reference the repository in other AWS resources.
  value       = aws_ecr_repository.repository.id
}

# Capture the name of the created ECR repository in an output variable
output "repository_name" {
  description = "The Name of the repository"
  value       = aws_ecr_repository.repository.name
}