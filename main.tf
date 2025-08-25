resource "random_id" "default" {
  byte_length = 8
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "default" {
  name     = "${random_id.default.hex}-terraform-remote-backend"
  location = var.region

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "local_file" "default" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.default.name}"
    }
  }
  EOT
}

resource "google_artifact_registry_repository" "company_repo" {
  location      = var.region
  repository_id = "company-repo"
  description   = "Company Repository"
  format        = "DOCKER"

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      older_than = "432000s"
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 3
    }
  }
}
