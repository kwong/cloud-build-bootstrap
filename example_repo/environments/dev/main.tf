/********************************************************
  terraform config for building out the dev environment
********************************************************/

locals {
  environment = "dev"
  subnet      = "10.10.10.0/24"
}

provider "google" {
  project = var.project
}


module "compute" {
  source      = "../../modules/compute"
  project     = var.project
  zone        = "asia-southeast1-a"
  environment = local.environment
  subnet      = module.vpc.subnet
}

module "vpc" {
  source      = "../../modules/vpc"
  project     = var.project
  environment = local.environment
  region      = "asia-southeast1"
  subnet      = local.subnet
}

# resource "google_compute_instance" "dev_instance" {
#   project      = var.project
#   zone         = "asia-southeast1-a"
#   name         = "gce-instance-dev"
#   machine_type = "n1-standard-1"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#     }
#   }

#   network_interface {
#     subnetwork = element(module.vpc.subnets_names, 0)
#   }

#   metadata = {
#     env = "dev"
#   }

# }

# module "vpc" {
#   source  = "terraform-google-modules/network/google"
#   version = "3.3.0"

#   project_id   = var.project
#   network_name = "dev"

#   subnets = [
#     {
#       subnet_name   = "dev-subnet-01"
#       subnet_ip     = "10.10.10.0/24"
#       subnet_region = "asia-southeast1"
#     },
#   ]

#   secondary_ranges = {
#     "dev-subnet-01" = []
#   }
# }
