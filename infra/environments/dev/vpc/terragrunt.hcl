terraform {
  source = "../../../modules/vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "limble-cmms-take-home"
  environment = "dev"
  region = "us-west-2"
}

