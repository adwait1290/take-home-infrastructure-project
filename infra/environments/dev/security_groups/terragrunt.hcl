dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "../../../modules/security_groups"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
}

