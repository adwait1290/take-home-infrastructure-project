dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security_groups"
}

terraform {
  source = "../../../modules/alb"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  alb_sg_id = dependency.security_groups.outputs.alb_sg_id
}

