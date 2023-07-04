# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Securely store the database username using AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_username" {
  name      = "/${local.common_tags.Name}/db/username"  # Parameter name based on common tags
  type      = "SecureString"  # Sensitive data that must be stored securely
  value     = var.db_username  # Value from variable
  overwrite = true  # Update the value if the parameter already exists
}

# Securely store the database password using AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name  = "/${local.common_tags.Name}/db/password"
  type  = "SecureString"
  value = var.db_password
  overwrite = true
}

# Securely store the database host using AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_host" {
  name  = "/${local.common_tags.Name}/db/host"
  type  = "SecureString"
  value = var.db_host
  overwrite = true
}

# Securely store the database name using AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_name" {
  name  = "/${local.common_tags.Name}/db/name"
  type  = "SecureString"
  value = var.db_name
  overwrite = true
}

# Secret Manager resource for Wordpress credentials
resource "aws_secretsmanager_secret" "wordpress" {
  name_prefix = "${local.common_tags.Name}-secret"  # Secret name based on common tags
  description = "Secrets for ECS Wordpress"  # Information about the purpose of the secret
  kms_key_id  = var.kms_key_id  # Key for encrypting the secret
  tags        = local.common_tags  # Tags for identifying the secret
}
# The secret manager provides an additional layer of security for sensitive data,
# and enables rotation and audit capabilities.

# Secret version for Wordpress credentials
resource "aws_secretsmanager_secret_version" "wordpress" {
  secret_id     = aws_secretsmanager_secret.wordpress.id  # ID from the secret resource
  secret_string = jsonencode({
    WORDPRESS_DB_HOST     = var.db_host
    WORDPRESS_DB_USER     = var.db_username
    WORDPRESS_DB_PASSWORD = var.db_password
    WORDPRESS_DB_NAME     = var.db_name
  })
}
# The secret version resource ensures that any update to these credentials
# are treated as the creation of a new version, which provides accountability
# and the ability to rollback.
