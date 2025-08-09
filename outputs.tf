
output "artifact_registry_uri" {
  description = "The URI of the Artifact Registry repository."
  value       = google_artifact_registry_repository.my_repo.name
}