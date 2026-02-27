
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
  schedule   = "0 17 * * *"  # run every day at 5 PM
  time_zone  = "UTC"

  env_vars = {
    Job__JobType                         = "CarrierDataSync"
    GCP__ProjectId                       = var.project_id,
    PubSub__CarrierSyncRequestTopicName  = module.carrier_sync_pubsub.topic_short,
    CarrierDataSync__DotNumbersStr       = "",
    CarrierDataSync__MaxCarriersToSync   = "10000",
    CarrierDataSync__SyncRequestTypesStr = "Carrier,DocketNumber,CargoCarried,Basics,Authority,Oos"
  }

  pubsub_topic_names   = [module.carrier_sync_pubsub.topic_name]
  hasAccessToFirestore = true
}

module "company-worker-job" {
  source     = "../../modules/cloud-run-job/scheduled-jobs"
  project_id = var.project_id
  location   = var.location
  name       = "company-worker-job"
  image      = "${var.location}-docker.pkg.dev/${var.project_id}/company-repo/company-ingestion-job:latest"
  cpu        = "1"
  memory     = "512Mi"
  timeout    = "3600s"       # 1 hour
  schedule   = "10 17 * * *"  # run every day at 5:10 PM
  time_zone  = "UTC"

  env_vars = {
    Job__JobType                         = "CarrierDataSyncWorker"
    GCP__ProjectId                       = var.project_id,
    PubSub__CarrierSyncSubscriptionName  = module.carrier_sync_pubsub.subscription_names["message"],
    PubSub__CarrierDataTopicName         = module.carrier_data_updates_pubsub.topic_short,
    SecretManager__SecretIds             = "FmcsaApi__WebKey",  
  }

  pubsub_topic_names   = [module.carrier_data_updates_pubsub.topic_name]
  subscription_names   = [module.carrier_sync_pubsub.subscription_names["message"]]
  secretIds            = [module.fmcsa_api_webkey_secret.secret_id]
}
