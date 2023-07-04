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

# The ID of the Amazon Virtual Private Cloud (Amazon VPC) where you're creating the DB instance.
variable "vpc_id" {
  description = "The ID of the VPC where RDS instance is to be created"
  type        = string
}

# Security Group ID associated with Database instance.
variable "rds_sg_id" {
  description = "Security Group ID for RDS instance"
  type        = string
}

# Amount of storage to allocate for your database instance in gigabytes.
variable "allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance"
  type        = number
}

# The compute and memory capacity of the Amazon RDS instance you want to create.
variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

# The name of your database that you want to create when the DB instance is created.
variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
}

# Master username for the database instance.
variable "db_username" {
  description = "The name for the master DB user"
  type        = string
}

# Master user password for the database instance.
variable "db_password" {
  description = "Password for the master DB user. Note that this will be stored in the raw state as plain-text"
  type        = string
  sensitive   = true # sensitive variable denoted here, Terraform uses this flag to hide the variable's value from CLI output.
}

# Specifies if the RDS instance is a Multi-AZ deployment.
# If true, the database is designed to automatically failover in case of outage by keeping a replica in a different Availability Zone.
variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
}

# List of private subnet IDs required for the DB instance. A private subnet allows outbound access to the internet through the internet gateway.
variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB"
  type        = list(string)
}

# Public subnets refer to subnets that are reachable from the internet.
variable "public_subnet_ids" {
  description = "List of public subnet IDs for the DB"
  type        = list(string)
}

