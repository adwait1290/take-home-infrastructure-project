# Produce outputs which can be consumed by other resources

# Output the RDS Security Group ID
# This SG ID can be used for other AWS services to interact with the RDS
output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

# Output the ECS Security Group ID
# This SG ID can be used for other AWS services to interact with the ECS service
output "ecs_sg_id" {
  description = "ECS Service Security Group ID"
  value = aws_security_group.ecs_service.id
}

# Output the EFS Service Security Group ID
# This SG ID can be used for other AWS services to interact with the EFS service
output "efs_sg_id" {
  description = "EFS Service Security Group ID"
  value = aws_security_group.efs_service.id
}

# Output the ALB Security Group ID
# This SG ID can be used for other AWS services to interact with the ALB
output "alb_sg_id" {
  description = "ALB Security Group ID"
  value = aws_security_group.alb.id
}