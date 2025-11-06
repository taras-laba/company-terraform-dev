
module "company-ingestion-archive-job" {
  source     = "../../modules/cloud-run-job/scheduled-jobs"
  project_id = var.project_id
  location   = var.location
  name       = "company-import-job"
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-job:latest"
  cpu        = "1"
  memory     = "1024Mi"
  timeout    = "3600s"      # 1 hour
  schedule   = "0 10 * * *" # run every day at 10 AM
  time_zone  = "UTC"

  env_vars = {
    Job__JobType                             = "CarrierCensusImport"
    GCP__ProjectId                           = var.project_id,
    PubSub__CarrierRegistrationDataTopicName = module.carrier_registration_updates_pubsub.topic_short,
    Import__ForceImportWhenAlreadyProcessed  = "true",
    Import__MaxRecordsToImport               = "100",
    Import__WorkingPath                      = "/data",
    SecretManager__SecretIds                 = "DataTransportationApi__ApiToken"
  }

  gcs_volumes = {
    "company-ingestion-data" = {
      bucket      = module.company_ingestion_storage_bucket.bucket_name
      read_only   = false
      mount_paths = ["/data"]
    }
  }

  pubsub_topic_names = [module.carrier_registration_updates_pubsub.topic_name]

  secretIds = [module.data_transportation_api_token_secret.secret_id]
}

module "company-ingestion-sync-job" {
  source     = "../../modules/cloud-run-job/scheduled-jobs"
  project_id = var.project_id
  location   = var.location
  name       = "company-sync-job"
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-job:latest"
  cpu        = "1"
  memory     = "512Mi"
  timeout    = "3600s"       # 1 hour
  schedule   = "50 16 * * *" # run every day at 4:35 PM
  time_zone  = "UTC"

  env_vars = {
    Job__JobType                        = "CarrierDataSync"
    GCP__ProjectId                      = var.project_id,
    PubSub__CarrierSyncRequestTopicName = module.carrier_sync_pubsub.topic_short,
    CarrierDataSync__DotNumbersStr      = "",
    CarrierDataSync__MaxCarriersToSync  = "100",
  }

  pubsub_topic_names   = [module.carrier_sync_pubsub.topic_name]
  hasAccessToFirestore = true
}
