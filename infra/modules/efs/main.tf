# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Generate a random password for the database
# Best Practice: Use random generated secret for increased security 
resource "random_password" "db_password" {
  length  = 16    # Defines password length
  special = false # No special characters to simplify password
}

# Create a new KMS Key to encrypt Wordpress related resources
# KMS Keys provide a secure way to store and manage secrets
resource "aws_kms_key" "wordpress" {
  description             = "KMS Key used to encrypt Wordpress related resources" 
  deletion_window_in_days = 7            # Specifies time before key can be deleted
  enable_key_rotation     = true         # Enable key rotation for increased security
  tags                    = local.common_tags # Apply the common tags
}

# Create a simple to remember alias for the KMS Key
# Allows the key to be accessed by a user-friendly name
resource "aws_kms_alias" "wordpress" {
  name          = "alias/wordpress"      # Define alias name
  target_key_id = aws_kms_key.wordpress.id # Link alias to the key
}

# Create an elastic filesystem to store Wordpress data
# EFS is scalable and high-performant storage, which is secure due to the associated KMS key
resource "aws_efs_file_system" "wordpress" {
  creation_token = "${local.common_tags.Name}-efs" 
  kms_key_id     = aws_kms_key.wordpress.arn  # Specifies the KMS key for the file system
  encrypted      = true # Encrypt files at rest for added data security
  tags           = local.common_tags # Apply the common tags
}

# Each EFS Filesystem will be available in the specified subnets
resource "aws_efs_mount_target" "wordpress" {
  count           = length(var.ecs_service_subnet_ids) # Amount depends on the number of provided subnets
  file_system_id  = aws_efs_file_system.wordpress.id   # Links mount target to the file system
  subnet_id       = var.ecs_service_subnet_ids[count.index] # ID of the subnet in which to place the mount target
  security_groups = [var.efs_sg_id] # Specifies the security group for the mount target
}

# Access point for "plugins" dir. Specifies owner and permissions
# Noteworthy: User ID (uid) and group ID (gid) are both '33' for standard www-data user
resource "aws_efs_access_point" "wordpress_plugins" {
  file_system_id = aws_efs_file_system.wordpress.id
  posix_user {
    gid = 33
    uid = 33
  }
  root_directory {
    path = "/plugins"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = 755 # Standard permissions for web dir (owner can read, write, execute. Others can read, execute)
    }
  }
}

# Access point for "themes" dir. Specifies owner and permissions
# Same uid,gid and permissions as "plugins" dir - segregating for better organisation
resource "aws_efs_access_point" "wordpress_themes" {
  file_system_id = aws_efs_file_system.wordpress.id
  posix_user {
    gid = 33
    uid = 33
  }
  root_directory {
    path = "/themes"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = 755 # Standard permissions for web dir
    }
  }
}

# TODO:/Recommendation: Use AWS IAM to control who can access these resources. Update security group rules to lock down access.
# Data backup strategies must be considered and implemented for business continuity. 