output "docker_repo_url" {
  description = "The URL of the Docker Artifact Registry repository"
  value       = "https://${google_artifact_registry_repository.company_repo.location}-docker.pkg.dev/${google_artifact_registry_repository.company_repo.project}/${google_artifact_registry_repository.company_repo.repository_id}"
}

output "carrier_registration_updates_topic_name" {
  description = "The name of the Pub/Sub topic for carrier registration updates"
  value       = google_pubsub_topic.carrier_registration_updates_topic.name
}
