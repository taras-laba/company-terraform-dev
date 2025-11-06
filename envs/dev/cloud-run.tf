module "company_ing_consumer_module_cloud_run" {
  source = "../../modules/cloud-run/company-ing-consumer-cloud-run"

  app_name   = "company-ingestion-consumer"
  location   = var.location
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-consumer:latest"
  project_id = var.project_id
  env_vars = {
    GCP__ProjectId            = var.project_id,
    Authentication__Audience  = "company-ingestion-consumer",
    Authentication__Authority = "https://accounts.google.com",
    ASPNETCORE_ENVIRONMENT    = "Development",
  }
  cpu                     = "1"
  memory                  = "512Mi"
  subscriptions_sa_emails = [module.carrier_registration_updates_pubsub.service_accounts["message"]]
}

module "company_sync_worker_module_cloud_run" {
  source = "../../modules/cloud-run/company-sync-worker-cloud-run"

  app_name   = "company-sync-worker"
  location   = var.location
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-consumer:latest"
  project_id = var.project_id
  env_vars = {
    GCP__ProjectId            = var.project_id,
    Authentication__Audience  = "company-sync-worker",
    Authentication__Authority = "https://accounts.google.com",
    ASPNETCORE_ENVIRONMENT    = "Development",
    SecretManager__SecretIds  = "FmcsaApi__WebKey"
    RateLimiting__IsEnabled   = "true",
    RateLimiting__QueueLimit  = "50"
  }
  cpu                     = "1"
  memory                  = "512Mi"
  max_instance_count      = 1
  subscriptions_sa_emails = [module.carrier_sync_pubsub.service_accounts["message"]]
  secretIds               = [module.fmcsa_api_webkey_secret.secret_id]
}

module "company_api_module_cloud_run" {
  source = "../../modules/cloud-run/company-api"

  app_name   = "company-api"
  location   = var.location
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-api:latest"
  project_id = var.project_id
  env_vars = {
    GCP__ProjectId         = var.project_id,
    ASPNETCORE_ENVIRONMENT = "Development",
  }
  cpu    = "1"
  memory = "512Mi"
}
