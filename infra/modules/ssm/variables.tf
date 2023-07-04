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

# Password for the database user.
# Setting 'sensitive' to true conceals the input/output of this variable in logs or regular output, offering an extra layer of security.
variable "db_password" {
  description = "Password for the database user. Marked as sensitive data, avoiding exposure in the logs."
  type        = string
  sensitive   = true
}

# Username for the database.
variable "db_username" {
  description = "Username for the database"
  type        = string
}

# Hostname (or IP address) of the machine where the database is hosted.
variable "db_host" {
  description = "Hostname (IP address) for connection to the database"
  type        = string
}

# Name of the database.
variable "db_name" {
  description = "Name of the database within the DB instance"
  type        = string
}

# The id of an AWS Key Management Service (AWS KMS) key that the Amazon RDS DB instance uses to encrypt data at rest.
variable "kms_key_id" {
  description = "The ID of the KMS key for encryption and decryption of the Amazon RDS DB instance data"
  type        = string
}