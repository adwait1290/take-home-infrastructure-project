dependency "vpc" {
  config_path = "../vpc"
}
dependency "security_groups" {
  config_path = "../security_groups"
}
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/efs"
}

inputs = {
  project_name        = "limble-cmms-take-home"
  environment         = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  ecs_service_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  efs_sg_id = dependency.security_groups.outputs.efs_sg_id
}

