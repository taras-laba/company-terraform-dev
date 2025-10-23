resource "google_storage_bucket" "google_storage_bucket_module" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class

   dynamic "lifecycle_rule" {
    for_each = var.object_lifetime_days != null ? [1] : []
    content {
      action {
        type = "Delete"
      }
      condition {
        age = var.object_lifetime_days
      }
    }
  }

  uniform_bucket_level_access = var.uniform_bucket_level_access
  
  dynamic "versioning" {
    for_each = var.enable_versioning ? [1] : []
    content {
      enabled = true
    }
  }
}