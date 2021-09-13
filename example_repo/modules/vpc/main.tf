
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "3.3.0"

  project_id   = var.project
  network_name = "${var.environment}-network"

  subnets = [
    {
      subnet_name   = "${var.environment}-subnet"
      subnet_ip     = var.subnet
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.environment}-subnet" = []
  }
}
