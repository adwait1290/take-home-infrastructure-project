dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security_groups"
}

terraform {
  source = "../../../modules/rds"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  rds_sg_id = dependency.security_groups.outputs.rds_sg_id
  allocated_storage = 400
  instance_class = "db.t3.micro"
  db_name = "dev_db"
  db_username = get_env("DB_USERNAME","defaultusername")
  db_password = get_env("DB_PASSWORD","defaultpassword")
  multi_az = false
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
}

