output "service_url" {
  description = "The URL of the Company API Cloud Run service"
  value       = google_cloud_run_v2_service.company_api_cloud_run.uri
}

output "service_account_email" {
  description = "The email of the Company API service account"
  value       = google_service_account.company_api_sa.email
}
