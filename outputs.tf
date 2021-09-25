output "sourcerepo_url" {
  description = "Source Repo created by the module"
  value       = [for s in google_sourcerepo_repository.source_repo : s.url]
}

output "cloudbuild_project_id" {
  description = "Project for Cloud Build"
  value       = module.cloudbuild_prj.project_id
}