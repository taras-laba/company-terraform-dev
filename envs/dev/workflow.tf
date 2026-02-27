module "company_ingestion_workflow" {
  source = "../../modules/workflow/company-ingestion-workflow"

  project_id = var.project_id
  location   = var.location
  carrier_sync_init_job_name = "company-sync-job"
  carrier_sync_worker_job_name = "company-worker-job"
  carrier_registration_subscription_name = module.carrier_registration_updates_pubsub.subscription_names["message"]
}