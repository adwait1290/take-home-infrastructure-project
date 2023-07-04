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

# Variable to hold the VPC ID.
variable "vpc_id" {
  description = "The ID of the VPC where the ALB is created"
}

# A list of IDs for the public subnets where the ALB is to be placed.
variable "public_subnet_ids" {
  description = "Public Subnet IDs where the ALB will be available"
  type        = list(string)
}

# Security Group ID for the ALB. This acts as a firewall that controls inbound and outbound
# traffic for the ALB, adding an extra layer of security.
variable "alb_sg_id" {
  type = string
}

# The Amazon Resource Name (ARN) of the certificate. Using HTTPS (SSL/TLS)
# instead of HTTP secures communication by encrypting the request
# and response. The default value is a dummy arn.
variable "cert_arn" {
  type = string
  default = "arn:aws:acm:us-west-2:777643725174:certificate/74bbfe47-0a5a-463e-a755-18c1163e0e4b"
}
