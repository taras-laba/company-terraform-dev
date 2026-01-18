resource "google_cloud_run_v2_service" "company_ing_consumer_module_cloud_run" {
  name                = var.app_name
  location            = var.location
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  custom_audiences    = ["company-ingestion-consumer"]

  template {
    service_account = google_service_account.company_ing_consumer_sa.email

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

resource "google_service_account" "company_ing_consumer_sa" {
  account_id   = "company-ing-consumer-sa"
  display_name = "Service Account for Company Ingestion Consumer in Cloud Run"
}

resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.company_ing_consumer_sa.email}"
}

resource "google_cloud_run_service_iam_binding" "company_ing_consumer_module_cloud_run_pubsub_invoker" {
  service  = google_cloud_run_v2_service.company_ing_consumer_module_cloud_run.name
  role     = "roles/run.invoker"
  project  = var.project_id
  location = var.location
  members  = [for email in var.subscriptions_sa_emails : "serviceAccount:${email}"]
}
