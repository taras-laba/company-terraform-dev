output "service_url" {
  value = google_cloud_run_v2_service.company_ing_consumer_module_cloud_run.uri
}

output "service_account_email" {
  description = "The email of the service account"
  value       = google_service_account.company_ing_consumer_sa.email
}
