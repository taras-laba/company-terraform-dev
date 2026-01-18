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
  subscriptions_sa_emails = [
    module.carrier_registration_updates_pubsub.service_accounts["message"],
    module.carrier_data_updates_pubsub.service_accounts["message"]
  ]
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
  read_secret_ids = [ module.data_protection_keys_secrets.secret_id ]
  write_secret_ids = [ module.data_protection_keys_secrets.secret_id ]
}
