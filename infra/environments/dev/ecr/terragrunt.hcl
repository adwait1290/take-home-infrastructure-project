terraform {
  source = "../../../modules/ecr"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment         = "dev"
}

