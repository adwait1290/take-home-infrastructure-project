# This data.tf file is responsible for fetching necessary data from the AWS infrastructure.

# Fetching existing AWS SSM parameters for db password, host, username and name.
# These parameters are stored securely in AWS Systems Manager Parameter Store.

data "aws_ssm_parameter" "db_password" {
  name = "/${local.common_tags.Name}/db/password" # Name of the parameter in Parameter Store
  with_decryption = true                         # Parameter value is returned decrypted
}

data "aws_ssm_parameter" "db_host" {
  name = "/${local.common_tags.Name}/db/host"     # Name of the parameter in Parameter Store
  with_decryption = true                         # Parameter value is returned decrypted
}

data "aws_ssm_parameter" "db_username" {
  name = "/${local.common_tags.Name}/db/username" # Name of the parameter in Parameter Store
  with_decryption = true                         # Parameter value is returned decrypted
}

data "aws_ssm_parameter" "db_name" {
  name = "/${local.common_tags.Name}/db/name"     # Name of the parameter in Parameter Store
  with_decryption = true                         # Parameter value is returned decrypted
}

# Retrieves the current AWS region - useful for deploying resources in the same region
data "aws_region" "current" {}

# Retrieves the current AWS caller identity information - useful for getting the AWS Account ID
data "aws_caller_identity" "current" {}

# AWS IAM policy document used to define permissions.
# This policy gives broad access to "kms:*" actions for the root user, as well giving specific actions for cloudwatch logs.
# It is a best practice to have least privilege permissions. This policy should be reviewed.

data "aws_iam_policy_document" "kms" {
  # First Statement:
  # This permits full access (kms:*) to KMS for the account's root user
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] #Root user ARN of the account
    }
    actions   = ["kms:*"] #Allows all actions on KMS
    resources = ["*"]     # TODO: TARGET RESOURCES
  }

  # Second Statement:
  # This allows relevant KMS actions for Cloudwatch Logs service
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"] #CloudWatch Logs ARN
    }
    actions = [ #These specified actions are permitted
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"] # This applies to all resources
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

# Trust Policy for ECS Tasks
# This policy allows ECS Tasks to assume a role
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    effect = "Allow"     # Allow the action
    principals {
      type = "Service"   # The principal is a service
      identifiers = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"] # Allow these ECS services
    }
    actions = ["sts:AssumeRole"] # The action allowed is to assume a role
  }
}

# IAM policy for the ECS Task
# This policy gives necessary access required for the ECS tasks to run
data "aws_iam_policy_document" "ecs_task_policy" {
  # Permissions for various AWS services that ECS may need to interact with
  statement {
    actions = [   # List of actions the ECS Task can perform
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeAccessPoints"
    ]
    effect    = "Allow"
    resources = ["*"]   # All resources TODO: TARGET RESOURCES
  }

  # Permissions to fetch secret values from AWS SecretsManager
  # This allows ECS tasks to receive & make use of sensitive data, such as passwords
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [var.ssm_arn_id] # It's limited to a particular parameter
  }

  # Permissions to decrypt using a KMS key
  # This allows ECS tasks to handle encrypted data securely
  statement {
    actions   = ["kms:Decrypt"]
    effect    = "Allow"
    resources = [aws_kms_key.wordpress.arn] # Here, it's for the Wordpress KMS key
  }
}

# Get built-in IAM policy for ECS FullAccess
# This policy provides ECS tasks all necessary permissions
data "aws_iam_policy" "ecs" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# Get built-in IAM policy for ECR FullAccess
# This policy provides ECS tasks necessary permissions to interact with ECR
data "aws_iam_policy" "ecr" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
#TODO:
# Note: Be careful with assigning policies and ensure minimum permissions are given to adhere to the principle of least privilege
# Important: Carefully review IAM policy documents to ensure they don't introduce any unnecessary permissions or security vulnerabilities.