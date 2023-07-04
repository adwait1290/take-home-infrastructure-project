## This is Terragrunt configuration for "prod" environment
include {
  path = find_in_parent_folders()
}

locals {
  # Define environment variables for prod
  environment_vars = {
    "Environment" : "prod"
    "DBPassword" : data.ssm_parameter.db_password.value
  }
}

terraform {
  # Fetch values from AWS SSM Parameter Store
  data "aws_ssm_parameter" "db_password" {
    name  = "/${local.environment_vars["Environment"]}/DB_PASSWORD"
  }
}

input = {
  environment_vars = local.environment_vars
}