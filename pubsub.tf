
resource "google_pubsub_topic" "carrier_registration_updates_topic" {
  project = var.project_id
  name    = "carrier-registration-updates"
}

resource "google_pubsub_subscription" "carrier_registration_updates_subscription" {
  name  = "carrier-registration-updates-subscription"
  topic = google_pubsub_topic.carrier_registration_updates_topic.name
}