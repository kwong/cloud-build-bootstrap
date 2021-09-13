locals {
  tf_sa = var.terraform_service_account
}

# use impersonated sa by default
provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
}
provider "google-beta" {
  access_token = data.google_service_account_access_token.default.access_token
}
provider "google" {
  alias = "impersonate"
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonate
  target_service_account = local.tf_sa
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "600s"
}

