resource "google_cloud_run_v2_service" "company_api_cloud_run" {
  name                = var.app_name
  location            = var.location
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.company_api_sa.email

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
    }
  }
}

resource "google_service_account" "company_api_sa" {
  account_id   = "company-api-sa"
  display_name = "Service Account for Company API in Cloud Run"
}

resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.company_api_sa.email}"
}

resource "google_service_account" "company_api_invoker_sa" {
  account_id   = "company-api-invoker-sa"
  display_name = "Service Account to invoke Company API in Cloud Run"
}

resource "google_cloud_run_service_iam_binding" "company_api_cloud_run_service_public" {
  service  = google_cloud_run_v2_service.company_api_cloud_run.name
  role     = "roles/run.invoker"
  project  = var.project_id
  location = var.location
  members  = ["allUsers", "serviceAccount:${google_service_account.company_api_invoker_sa.email}"]
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each  = toset(var.read_secret_ids)
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.company_api_sa.email}"

  depends_on = [google_service_account.company_api_sa]
}

resource "google_secret_manager_secret_iam_member" "secret_viewer" {
  for_each = toset(var.read_secret_ids)

  secret_id = each.value
  role      = "roles/secretmanager.viewer"
  member    = "serviceAccount:${google_service_account.company_api_sa.email}"

  depends_on = [google_service_account.company_api_sa]
}

resource "google_secret_manager_secret_iam_member" "secret_version_adder" {
  for_each = toset(var.write_secret_ids)

  secret_id = each.value
  role      = "roles/secretmanager.secretVersionAdder"
  member    = "serviceAccount:${google_service_account.company_api_sa.email}"

  depends_on = [google_service_account.company_api_sa]
}