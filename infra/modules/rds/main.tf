# Use locals to define a common set of tags for easy resource identification and environment isolation
locals {
  # These tags get applied to all resources for easier management and identification
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Defines an AWS DB instance that gets created and managed by Terraform
resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage        # Define the amount of storage provisioned for the database instance
  storage_type           = "gp2"                        # Use GP2 storage for optimal performance in most general purpose applications
  engine                 = "mariadb"                    # Define the database engine to be used. Here it's `mariadb`
  engine_version         = "10.6.10"                    # Specifies the specific version of the database engine
  instance_class         = var.instance_class           # Define the class of the DB instance which affects performance and cost
  db_name                = var.db_name                  # Defines the initial database name upon DB instance creation
  username               = var.db_username              # Defines the username for database access
  password               = var.db_password              # Defines the password for database access. Insecure in this file. Use AWS secrets manager or similar tool to manage securely
  parameter_group_name   = aws_db_parameter_group.default.name # Links to the db parameter group created below
  vpc_security_group_ids = [var.rds_sg_id]              # Security group ID associated with this DB instance, for security control
  multi_az               = var.multi_az                 # Better performance, and fault tolerance via Multi Availability Zone deployment. Set as per your requirement.
  publicly_accessible    = true                         # Should be set to false in production environments for security reasons but since we have a SG acting as a whitelist, this is mitigated.
  skip_final_snapshot    = true                         # Terraform will not create a final snapshot of the DB upon deletion. Set to false if you want to retain a snapshot.
  db_subnet_group_name   = aws_db_subnet_group.default.name  # Links to the db subnet group created below
  tags                   = local.common_tags            # Apply common tags to this resource
}

# This resource represents a DB subnet group to hold subnets that the RDS instance could be put in
resource "aws_db_subnet_group" "default" {
  name       = "${local.common_tags.Name}-db_subnet_group" # The name of the DB subnet group
  subnet_ids = var.public_subnet_ids                       # List of IDs of subnets to associate with this group
  tags       = local.common_tags                           # Apply common tags to this resource
}

# This resource represents a Parameter Group for an RDS Instance, to manage DB engine configuration parameters
resource "aws_db_parameter_group" "default" {
  name   = "${local.common_tags.Name}-db-parameter-group"    # The name of the DB parameter group
  family = "mariadb10.6"                                     # The family of the DB parameter group

  # Apply common tags to this resource
  tags   = local.common_tags

  # Define parameters for this group
  parameter {
    name         = "max_allowed_packet"                      # Specific parameter name
    value        = "52428800"                                # Value for the above parameter
    apply_method = "immediate"                               # How the parameter gets applied. 'immediate' takes effect immediately
  }
}