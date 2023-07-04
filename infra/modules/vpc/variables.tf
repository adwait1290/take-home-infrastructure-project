# Definition of input variables which are used to customize our script according to environment, and for reusability of code

# Declare a variable to hold project name. It acts as identifier for all resources
# to easily track and manage them in large infrastructure.
variable "project_name" {
  description = "Name to be used on all the resources as identifier."
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

# AWS region in which to deploy the resources
# It is one of the most trafficked AWS regions and provides a good default for most use cases.
# only give you recommendations on formatting and comments. However, you may want to consider setting the 'default' region based on your organizational preference or specific application needs.
variable "region" {
  description = "The AWS region in which resources will be provisioned."
  type        = string
  default     = "us-west-2"
}

# CIDR block for the VPC - Specifies the overall network range
# Recommendation: Always plan the network range carefully, depending on the projected scaling needs of your application.
# The 'default' value of "10.0.0.0/16" is a commonly used private network range giving you up to 65,536 IP addresses, perfect for any industry standard applications.
variable "vpc_cidr" {
  description = "The CIDR block for the VPC which specifies the overall IPv4 network range."
  type        = string
  default     = "10.0.0.0/16"
}