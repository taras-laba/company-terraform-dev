provider "google" {
  project     = var.project_id
  credentials = file("C:\\Users\\Taras\\taras-laba-dev-10f8f54482c7.json")
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
        older_than   = "432000s"
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
        keep_count  = 3
    }
  }
}
