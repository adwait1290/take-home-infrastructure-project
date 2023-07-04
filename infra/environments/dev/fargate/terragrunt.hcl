dependency "vpc" {
  config_path = "../vpc"
}
dependency "security_groups" {
  config_path = "../security_groups"
}
dependency "alb" {
  config_path = "../alb"
}

dependency "efs" {
  config_path = "../efs"
}

dependency "ecr" {
  config_path = "../ecr"
}

dependency "rds" {
  config_path = "../rds"
}
dependency "ssm" {
  config_path = "../ssm"
}
terraform {
  source = "../../../modules/fargate"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  ecr_repository_id = dependency.ecr.outputs.repository_id
  ssm_arn_id = dependency.ssm.outputs.ssm_arn_id
  ecs_sg_id = dependency.security_groups.outputs.ecs_sg_id
  efs_sg_id = dependency.security_groups.outputs.efs_sg_id
  rds_sg_id = dependency.security_groups.outputs.rds_sg_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  webapp_port = 80
  desired_task_count = 2
  kms_key_id = dependency.efs.outputs.kms_key_id
  alb_tg_arn = dependency.alb.outputs.alb_tg_arn
  ecs_service_assign_public_ip = true
  ecs_task_definition_cpu = 2048
  ecs_task_definition_memory = 4096
  secret_manager_name = dependency.ssm.outputs.secret_manager_name
  efs_id = dependency.efs.outputs.efs_id
  wordpress_themes_access_point_id = dependency.efs.outputs.wordpress_themes_access_point_id
  wordpress_plugins_access_point_id = dependency.efs.outputs.wordpress_plugins_access_point_id
}
