# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Create a new ECR repository
resource "aws_ecr_repository" "repository" {
  # Name is a combination of project name and environment for easy identification
  name                 = "${local.common_tags.Name}-ecr-repo"

  # image_tag_mutability set to MUTABLE allows you to overwrite image tags
  # Consider 'IMMUTABLE' for production environments to prevent overwriting.
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    # Enable scan_on_push to automatically scan images on push. This helps to discover
    # software vulnerabilities in your Docker images
    scan_on_push = true
  }

  # Apply the common tags
  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "policy" {
  # Link the lifecycle policy to the ECR repository
  repository = aws_ecr_repository.repository.name

  # A lifecycle policy to automatically clean up old images
  policy = <<EOF
 {
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countNumber": 14,
        "countUnit": "days"
      },
      "action": {
        "type": "expire"
      }
    }
  ]
 }
EOF
}