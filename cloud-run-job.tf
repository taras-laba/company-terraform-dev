data "google_project" "current" {}

resource "google_storage_bucket" "company_ingestion_job_bucket" {
  name          = "company-ingestion-job-bucket"
  location      = var.region
  storage_class = "STANDARD"
  project       = var.project_id
}

resource "google_cloud_run_v2_job" "company_ingestion_job" {
  name     = "company-ingestion-job"
  location = var.region

  deletion_protection = false # set to "true" in production

  template {
    template {
      timeout = "3600s"

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-job:latest"
        volume_mounts {
          name       = "gcs-volume"
          mount_path = "/downloads"
        }
        env {
          name  = "GCP__ProjectId"
          value = var.project_id
        }
        env {
          name  = "PubSub__CarrierRegistrationDataTopicName"
          value = google_pubsub_topic.carrier_registration_updates_topic.name
        }
        env {
          name  = "FmcsaArchive__ForceImportWhenAlreadyProcessed"
          value = "true"
        }
        env {
          name  = "FmcsaArchive__MaxRecordsToProcess"
          value = "10"
        }
      }
      volumes {
        name = "gcs-volume"
        gcs {
          bucket    = google_storage_bucket.company_ingestion_job_bucket.name
          read_only = false
        }
      }
    }
  }
}

resource "google_cloud_scheduler_job" "cloud_run_job_scheduler" {
  region = var.region
  name        = "ingestion-job-scheduler"
  description = "Schedules execution of my Cloud Run Job"
  schedule    = "0 12 * * *" # Runs daily at 12:00 PM UTC
  time_zone   = "America/New_York" # Specify the desired timezone

  http_target {
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.company_ingestion_job.name}:run"
    http_method = "POST"
    oauth_token {
      service_account_email = google_service_account.cloud_run_invoker.email
    }
  }
}

resource "google_service_account" "cloud_run_invoker" {
  account_id   = "cloud-run-invoker"
  display_name = "Service Account for Cloud Run Job Invocation"
}

resource "google_project_iam_member" "cloud_run_job_invoker_binding" {
  project = var.project_id
  role    = "roles/run.invoker" # Grant permission to invoke Cloud Run Jobs
  member  = "serviceAccount:${google_service_account.cloud_run_invoker.email}"
}