# Use locals to define a common set of tags for easy resource identification and environment isolation
# Define local variables
locals {
  # Commonly used tags
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }

  # Retrieve Database parameters
  db_password = data.aws_ssm_parameter.db_password.value
  db_host     = data.aws_ssm_parameter.db_host.value
  db_username = data.aws_ssm_parameter.db_username.value
  db_name     = data.aws_ssm_parameter.db_name.value
}

# Create IAM Role for ECS tasks
# This allows the services to make calls to other AWS services on your behalf
resource "aws_iam_role" "ecs_task_role" {
  name               = "wordpressTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

# Attach the ECS IAM Policy to the role
# Allows the tasks to use ECS capabilities such as logging, etc.
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.ecs.arn
}

# Attach ECR Policy to the ECS role
# Allows the tasks to pull Docker images from ECR
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.ecr.arn
}

# Create a custom policy for ECS tasks
# The specific permissions in this policy will be determined
# by the policies defined in data.aws_iam_policy_document.ecs_task_policy.json
resource "aws_iam_policy" "ecs_task_policy" {
  name   = "wordpressTaskPolicy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

# Attach this custom policy to the ECS role
resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# Create a KMS Key
# This key is used to encrypt WordPress related resources
# It increases security by ensuring only services with the necessary permissions can decrypt these resources
resource "aws_kms_key" "wordpress" {
  description             = "KMS Key used to encrypt Wordpress related resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Helps improve security by rotating the key automatically
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = local.common_tags
}

# Create a Log Group for WordPress
# Logs are retained for 14 days and can be used for tracking and debugging purposes
resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "${local.common_tags.Name}-cloudwatch-logs-ecs"
  retention_in_days = 14
  tags              = local.common_tags
}

# Creating an ECS cluster for the WordPress service
resource "aws_ecs_cluster" "wordpress" {
  name = "${local.common_tags.Name}-cluster"
  tags = local.common_tags
}

# Define Task Definition for WordPress
# It contains the Docker runtime configuration for the service
# MySQL database details are stored as Docker secrets which greatly enhances security
# Define the ECS Task Definition for WordPress
resource "aws_ecs_task_definition" "wordpress" {
  family = "wordpress"

  # Define the parameters for the Docker containers that will run as tasks
  container_definitions = templatefile(
    "${path.module}/wordpress.tpl",
    {
      # Container and Docker image details
      ecs_service_container_name = "${local.common_tags.Name}-container-name"
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-west-2.amazonaws.com/${local.common_tags.Name}-ecr-repo"

      # Database and AWS specific parameters
      db_host = local.db_host
      db_username = local.db_username
      db_name = local.db_name
      db_password = local.db_password
      aws_region = "us-west-2"
      aws_logs_group = aws_cloudwatch_log_group.wordpress.name
      aws_account_id = data.aws_caller_identity.current.account_id
      secret_name = var.secret_manager_name
      cloudwatch_log_group = var.ecs_cloudwatch_logs_group_name
      ecr_repository_id = var.ecr_repository_id
    }
  )

  # Network configuration for the tasks
  network_mode  = "awsvpc"

  # Task compatibility and resource allocation
  requires_compatibilities = ["FARGATE"]
  cpu = var.ecs_task_definition_cpu
  memory = var.ecs_task_definition_memory

  # The IAM role the task will assume
  execution_role_arn = aws_iam_role.ecs_task_role.arn

  # Define the volumes to be attached to the tasks - here, EFS volumes for Wordpress themes and plugins are attached
  volume {
    name = "efs-themes"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.wordpress_themes_access_point_id
      }
    }
  }
  volume {
    name = "efs-plugins"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.wordpress_plugins_access_point_id
      }
    }
  }

  tags = local.common_tags
}

# Create the ECS service for WordPress
resource "aws_ecs_service" "wordpress" {
  name            = "${local.common_tags.Name}-service"
  cluster         = aws_ecs_cluster.wordpress.arn
  task_definition = aws_ecs_task_definition.wordpress.arn

  # Service level configuration
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  propagate_tags = "SERVICE"

  # Network configuration for the service
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  # Load Balancer configuration
  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "${local.common_tags.Name}-container-name"
    container_port   = "80"
  }

  tags = local.common_tags
}