module "carrier_registration_updates_pubsub" {
  source = "../../modules/pubsub"

  topic_name = "carrier-registration-updates"
  project_id = var.project_id

  endpoints = {
    message = {
      push_endpoint = "${module.company_ing_consumer_module_cloud_run.service_url}/api/carrier-registration"
      audience      = "company-ingestion-consumer"
    }
  }
}

module "carrier_sync_pubsub" {
  source = "../../modules/pubsub"

  topic_name = "carrier-sync"
  project_id = var.project_id
  
  endpoints = {
    message = {
      push_endpoint = "not-used"
      enable_push = false
    }
  }
}

module "carrier_data_updates_pubsub" {
  source = "../../modules/pubsub"

  topic_name = "carrier-data-updates"
  project_id = var.project_id
  
  endpoints = {
    message = {
      push_endpoint = "${module.company_ing_consumer_module_cloud_run.service_url}/api/carrier-data"
      audience      = "company-ingestion-consumer"
    }
  }
}
