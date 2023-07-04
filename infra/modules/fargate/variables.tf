# Definition of input variables which are used to customize our script according to environment, and for reusability of code

# Declare a variable to hold project name. It acts as identifier for all resources
# to easily track and manage them in large infrastructure.
variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

# Define the environment where the deployment will take place.
# Default value is 'dev' indicating a development environment.
# It could be fed with other values such as 'prod' for production environment,
# which could help dictate different resource behavior as per the environment.
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# ECR Repository ID
variable "ecr_repository_id" {
  description = "The ID of the ECR repository."
  type        = string
}

# Amazon Resource Name (ARN) for AWS SSM
variable "ssm_arn_id" {
  description = "The ARN ID of the AWS Simple Systems Manager (SSM)."
  type        = string
}

# Security Group ID for ECS Fargate Service
variable "ecs_sg_id" {
  description = "The ID of the security group used for the ECS Fargate service."
  type        = string
}

# Security Group ID for EFS Fargate Service
variable "efs_sg_id" {
  description = "The ID of the security group used for the ECS Fargate service with EFS."
  type        = string
}

# Security Group ID for RDS Fargate Service
variable "rds_sg_id" {
  description = "The ID of the security group used for the ECS Fargate service with RDS."
  type        = string
}

# List of VPC Private Subnet IDs
variable "private_subnet_ids" {
  description = "A list of IDs for private subnets within your VPC."
  type        = list(string)
}

# List of VPC Public Subnet IDs
variable "public_subnet_ids" {
  description = "A list of IDs for public subnets within your VPC."
  type        = list(string)
}

# Port for the Web Application
variable "webapp_port" {
  description = "The port on which the web application will be listening."
  type        = number
}

# Desired number of tasks for ECS
variable "desired_task_count" {
  description = "The number of tasks that the ECS service should maintain."
  type        = number
}

# KMS Key ID (for encrypting logs)
variable "kms_key_id" {
  description = "The ID of the KMS key used to encrypt the CloudWatch logs."
  type        = string
}

# ARN of the Application Load Balancer
variable "alb_tg_arn" {
  description = "ARN (Amazon Resource Number) of the Application Load Balancer."
  type        = string
}

# Name of the CloudWatch Log Group for ECS
variable "ecs_cloudwatch_logs_group_name" {
  description = "Name of the AWS CloudWatch Log Group for AWS ECS."
  type        = string
  default     = "/ecs/wordpress"
}

# Whether to assign a public IP to the task ENIs
variable "ecs_service_assign_public_ip" {
  description = "Bool value to decide if a public IP will be assigned to the tasks or not."
  type        = bool
  default     = false
}

# Number of CPU units to reserve for the container
variable "ecs_task_definition_cpu" {
  description = "The number of CPU units to reserve for the ECS container. It must be an integer string value in powers of 2 (ex: '', '1024' = 1 vCPU, '2048' = 2 vCPUs)."
  type        = string
  default     = "1024"
}

# Memory to allocate to the ECS tasks
variable "ecs_task_definition_memory" {
  description = "The amount of memory to allocate to the ECS tasks. It must be an integer string value."
  type        = string
  default     = "2048"
}

# Secret Manager Name
variable "secret_manager_name" {
  description = "The Name of the AWS Secrets Manager."
  type        = string
}

# ID for EFS file system
variable "efs_id" {
  description = "The ID of the Elastic File System (EFS)."
  type        = string
}

# Access point ID for WordPress themes
variable "wordpress_themes_access_point_id" {
  description = "The ID of the EFS access point for WordPress themes."
  type        = string
}

# Access point ID for WordPress plugins
variable "wordpress_plugins_access_point_id" {
  description = "The ID of the EFS access point for WordPress plugins."
  type        = string
}