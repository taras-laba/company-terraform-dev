module "company_ingestion_storage_bucket" {
  source = "../../modules/storage-bucket"

  project_id  = var.project_id
  bucket_name = "taras-laba-dev-company-ingestion-bucket"
  location    = var.location
}
