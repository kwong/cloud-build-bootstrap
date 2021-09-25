locals {
  trigger_names          = [for i in setproduct(var.source_repos, var.branch_triggers) : join("-", i)]
  artifact_registry_name = "container-repo"
}

resource "random_id" "suffix" {
  byte_length = 2
}

# data "google_organization" "org" {
#   organization = var.org_id
# }

# CloudBuild Project

module "cloudbuild_prj" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 10.3.2"
  name                        = "${var.project_prefix}-test-cloudbuild"
  random_project_id           = true
  disable_services_on_destroy = false
  org_id                      = var.org_id
  billing_account             = var.billing_account


  labels = {
    primary_contact = "admin_at_example_dot_com"
  }

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com"
  ]

}

resource "google_sourcerepo_repository" "source_repo" {
  for_each = toset(var.source_repos)
  project  = module.cloudbuild_prj.project_id
  name     = each.value
}

/* CloudBuild Trigger */

resource "google_cloudbuild_trigger" "build_trigger" {
  for_each    = toset(local.trigger_names)
  project     = module.cloudbuild_prj.project_id
  description = each.value

  trigger_template {
    branch_name = "^(${regex(join("|", var.branch_triggers), each.value)})$"
    repo_name   = regex(join("|", var.source_repos), each.value)
  }

  substitutions = {
    _ARTIFACT_BUCKET = google_storage_bucket.artifact_bkt.name
    _REPO_NAME       = "$(csr.name)"
  }

  filename = "cloudbuild.yaml"
  depends_on = [
    google_sourcerepo_repository.source_repo
  ]



}

/* Artifact bucket */

resource "google_storage_bucket" "artifact_bkt" {
  project                     = module.cloudbuild_prj.project_id
  name                        = format("%s-%s-%s", var.project_prefix, "artifact-bkt", random_id.suffix.hex)
  location                    = var.default_region
  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

/* Image Repository */
resource "google_artifact_registry_repository" "artifact_registry" {
  provider      = google-beta
  project       = module.cloudbuild_prj.project_id
  location      = var.default_region
  repository_id = local.artifact_registry_name
  description   = "Docker repository"
  format        = "DOCKER"
}



/* Crypto (optional) */

# resource "google_kms_key_ring" "cloudbuild_keyring" {
#   project  = module.cloudbuild_prj.project_id
#   name     = "cloudbuild_keyring"
#   location = var.default_region
# }

# resource "google_kms_crypto_key" "cloudbuild_key" {
#   name     = "cloudbuild_key"
#   key_ring = google_kms_key_ring.cloudbuild_keyring.self_link
# }

# /* IAM */
# resource "google_kms_crypto_key_iam_binding" "cloudbuild_key_decrypter" {
#   crypto_key_id = google_kms_crypto_key.cloudbuild_key.self_link
#   role          = "roles/cloudkms.cryptoKeyDecrypter"

#   members = [
#     "serviceAccount:${module.cloudbuild_prj.project_number}@cloudbuild.gserviceaccount.com",
#     "serviceAccount:${var.terraform_service_account}"
#   ]
# }

resource "google_organization_iam_member" "network_admin" {
  org_id = var.org_id
  role   = "roles/compute.networkAdmin"
  member = "serviceAccount:${module.cloudbuild_prj.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "instance_admin" {
  org_id = var.org_id
  role   = "roles/compute.admin"
  member = "serviceAccount:${module.cloudbuild_prj.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "artifactregistry_admin" {
  provider   = google-beta
  project    = module.cloudbuild_prj.project_id
  location   = google_artifact_registry_repository.artifact_registry.location
  repository = google_artifact_registry_repository.artifact_registry.name
  role       = "roles/artifactregistry.admin"
  member     = "serviceAccount:${module.cloudbuild_prj.project_number}@cloudbuild.gserviceaccount.com"
}
