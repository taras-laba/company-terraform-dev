# resource "google_project_service_identity" "pubsub_agent" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "pubsub.googleapis.com"
# }

# resource "google_project_iam_binding" "project_token_creator" {
#   project = var.project_id
#   role    = "roles/iam.serviceAccountTokenCreator"
#   members = ["serviceAccount:${google_project_service_identity.pubsub_agent.email}"]
# }

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
