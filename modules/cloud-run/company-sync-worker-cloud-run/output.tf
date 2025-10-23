output "service_url" {
  value = google_cloud_run_v2_service.company_sync_worker_module_cloud_run.uri
}
