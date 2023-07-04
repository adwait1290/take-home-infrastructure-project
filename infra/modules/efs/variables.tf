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

# Defines the VPC ID where resources will be deployed
# Vital input as it provides network isolation for your resources
variable "vpc_id" {
  type        = string   # Data type is string
  description = "VPC ID where resources will be created" # Description for clarity
}

# Defines the Subnet IDs for the ECS Service
# This aids in network partitioning and improves the security of your ECS services
variable "ecs_service_subnet_ids" {
  type        = list(string)     # Expected data type is list of strings
  description = "List of IDs for ECS Service Subnets" # Description for clarity
}

# Defines the security group for EFS storage
# Security groups act as a virtual firewall for resources
variable "efs_sg_id" {
  type        = string  # Data type is string
  description = "Security Group for EFS" # Description for clarity
}

# Defines the CIDR blocks for the public subnets
# An important aspect of network architecture and affects how network resources communicate with each other
variable "public_subnet_cidr" {
  type        = list(string) # Expected data type is list of strings
  description = "List of CIDR blocks for the public subnets" # Description for clarity
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Default values provided
}



