locals {
  gcs_volume_mounts = flatten([
    for gcs_volume_key, gcs_volume in var.gcs_volumes : [
      for mount_path in gcs_volume.mount_paths : {
        key             = "${gcs_volume_key}:${mount_path}"
        gcs_volume_name = gcs_volume_key
        mount_path      = mount_path
      }
    ]
  ])
}

resource "google_service_account" "job_runner_account" {
  account_id   = "${var.name}-sa"
  display_name = "SA for ${var.name} job"
}

resource "google_cloud_run_v2_job" "job" {
  name                = var.name
  location            = var.location
  project             = var.project_id
  deletion_protection = false

  template {

    template {
      timeout = var.timeout
      containers {
        image = var.image
        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "volume_mounts" {
          for_each = local.gcs_volume_mounts
          content {
            name       = volume_mounts.value.gcs_volume_name
            mount_path = volume_mounts.value.mount_path
          }
        }
      }

      dynamic "volumes" {
        for_each = var.gcs_volumes
        content {
          name = volumes.key
          gcs {
            bucket    = volumes.value.bucket
            read_only = volumes.value.read_only
          }
        }
      }

      service_account = google_service_account.job_runner_account.email
    }
  }
}

resource "google_storage_bucket_iam_member" "job_runner_bucket_access" {
  for_each = var.gcs_volumes

  bucket = each.value.bucket
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.job_runner_account.email}"
}

resource "google_pubsub_topic_iam_member" "job_runner_pubsub_publisher_bindings" {
  for_each = toset(var.pubsub_topic_names)

  topic  = each.value
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.job_runner_account.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each  = toset(var.secretIds)
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.job_runner_account.email}"

  depends_on = [google_service_account.job_runner_account]
}

resource "google_service_account" "scheduler_sa" {
  account_id   = "${var.name}-sch-sa"
  display_name = "SA for ${var.name} scheduler"
}

resource "google_project_iam_member" "scheduler_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

resource "google_cloud_scheduler_job" "scheduler" {
  name        = "${var.name}-schedule"
  project     = var.project_id
  region      = var.location
  description = "Scheduler for ${var.name}"

  schedule  = var.schedule
  time_zone = var.time_zone

  http_target {
    http_method = "POST"
    uri         = "https://${var.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.job.name}:run"

    oauth_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}
