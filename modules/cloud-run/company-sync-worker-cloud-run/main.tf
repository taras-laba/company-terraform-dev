resource "google_cloud_run_v2_service" "company_sync_worker_module_cloud_run" {
  name                = var.app_name
  location            = var.location
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  custom_audiences    = ["company-sync-worker"]

  template {
    service_account = google_service_account.company_sync_worker_sa.email

    containers {
      image = var.image
      startup_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          path = "/healthz"
        }
      }
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
    }
  }
}

resource "google_service_account" "company_sync_worker_sa" {
  account_id   = "company-sync-worker-sa"
  display_name = "Service Account for Company Sync Worker in Cloud Run"
}

resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.company_sync_worker_sa.email}"
}

resource "google_cloud_run_service_iam_binding" "company_sync_worker_module_cloud_run_pubsub_invoker" {
  for_each = toset(var.subscriptions_sa_emails)

  service  = google_cloud_run_v2_service.company_sync_worker_module_cloud_run.name
  role     = "roles/run.invoker"
  project  = var.project_id
  location = var.location
  members  = ["serviceAccount:${each.value}"]
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each  = toset(var.secretIds)
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.company_sync_worker_sa.email}"

  depends_on = [google_service_account.company_sync_worker_sa]
}
