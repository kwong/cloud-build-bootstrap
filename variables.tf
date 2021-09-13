variable "org_id" {}
variable "project_prefix" {
  default = "prj"
}

variable "billing_account" {}
variable "terraform_service_account" {}
variable "default_region" {}
#variable "repo_name" {}

variable "source_repos" {
  description = "Cloud Source Repositories that should be created"
  type        = list(string)
  default     = ["gcp_test_repo"]
}

variable "branch_triggers" {
  description = "List containing Git branch names"
  type        = list(string)
  default     = ["prod", "dev"]

}
