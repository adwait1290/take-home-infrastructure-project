terraform {
  source = "../../../modules/ssm"
}

dependency "efs" {
  config_path = "../efs"
}

dependency "rds" {
  config_path = "../rds"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  db_username = get_env("DB_USERNAME", "defaultusername")
  db_password = get_env("DB_PASSWORD", "defaultpassword")
  db_host = dependency.rds.outputs.db_host
  db_name = dependency.rds.outputs.db_name
  kms_key_id = dependency.efs.outputs.kms_key_id
}

