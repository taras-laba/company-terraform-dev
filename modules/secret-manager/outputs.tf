output "secret_id" {
  description = "The ID of the created secret"
  value       = google_secret_manager_secret.secret.secret_id
}

output "secret_name" {
  description = "The full name of the created secret"
  value       = google_secret_manager_secret.secret.name
}