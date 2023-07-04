# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# EFS service security group:
# A security group acts as a virtual firewall, controlling inbound and outbound traffic.
resource "aws_security_group" "efs_service" {
  name        = "${local.common_tags.Name}-efs_service-sg" # Naming conventions helps in resource isolation.
  description = "Security group for Elastic File System (EFS)."
  vpc_id      = var.vpc_id
}

# Allowing inbound traffic from ECS service over port 2049(TCP Protocol - NFS).
# This helps establishing communication from ECS to EFS where EFS acts as a shared storage volume.
resource "aws_security_group_rule" "efs_service_ingress_nfs_tcp" {
  type                     = "ingress"
  description              = "Allow NFS from ECS service"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service.id
  security_group_id        = aws_security_group.efs_service.id
}

# Create ALB-SG with defined inbound and outbound traffic rules.
# This helps secure the load balance on all the required ports.
resource "aws_security_group" "alb" {
  name        = "${local.common_tags.Name}-alb-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id
  # TODO: PICK ONE
  # Define inbound rules allowing all traffic on HTTP 80
  # Also HTTPS traffic on port 443.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic on HTTP port"
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic on custom HTTP port"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic on HTTPS port"
  }

  # Define egress rule to allow all traffic out of the ALB.
  # This is required to route requests to the appropriate services.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# ECS service SG with an Egress Rule.
# Egress rule allows outbound traffic and is essential for instances within the security group to communicate with each other.
resource "aws_security_group" "ecs_service" {
  name        = "${local.common_tags.Name}-ecs_service-sg"
  description = "Wordpress ECS service Security Group"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define inbound rules to allow incoming HTTP and HTTPS traffic from the ALB.
resource "aws_security_group_rule" "ecs_service_ingress_http" {
  type                     = "ingress"
  description              = "Allow HTTP from load balancer"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_service_ingress_https" {
  type                     = "ingress"
  description              = "Allow HTTPS from load balancer"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_service.id
}

# Allow outbound MySQL and EFS traffic to facilitate communication with RDS and EFS respectively.
resource "aws_security_group_rule" "ecs_service_egress_mysql" {
  type                     = "egress"
  description              = "Allow MySQL traffic"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
  security_group_id        = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_service_egress_efs_tcp" {
  type                     = "egress"
  description              = "Allow EFS traffic"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs_service.id
  security_group_id        = aws_security_group.ecs_service.id
}

# RDS Security Group: Controls inbound and outbound traffic for your RDS instances.
# Here, we're allowing inbound traffic for MySQL over port 3306 from the ECS service.
resource "aws_security_group" "rds_sg" {
  name        = "${local.common_tags.Name}-db_sg"
  description = "Allow inbound traffic for MySQL RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  # Defining the egress rule (outbound traffic) for RDS Instance helps control over how it communicates with other AWS Services
  # For this script it isn't strictly necessary (You can cut it for a more restrictive setup)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Added common tags for uniformity across resources and better management.
  tags = local.common_tags
}