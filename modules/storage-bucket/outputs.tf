output "bucket_name" {
  value = google_storage_bucket.google_storage_bucket_module.name
  description = "The name of the GCS bucket"
}