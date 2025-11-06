data "google_project" "current" {
  project_id = var.project_id
}

# Main topic
resource "google_pubsub_topic" "main" {
  name    = var.topic_name
  project = var.project_id
}

# Create subscriptions for each endpoint
resource "google_pubsub_subscription" "subscriptions" {
  for_each = var.endpoints

  name    = "${var.topic_name}-${each.key}-subscription"
  topic   = google_pubsub_topic.main.name
  project = var.project_id

  enable_message_ordering = each.value.is_fifo

  # Push configuration
  dynamic "push_config" {
    for_each = each.value.enable_push ? [1] : []
    content {
      push_endpoint = each.value.push_endpoint

      # Authentication configuration
      dynamic "oidc_token" {
        for_each = each.value.enable_authentication ? [1] : []
        content {
          service_account_email = each.value.service_account_email != "" ? each.value.service_account_email : google_service_account.push_auth[each.key].email
          audience              = each.value.audience != "" ? each.value.audience : each.value.push_endpoint
        }
      }

      # Payload unwrapping
      dynamic "no_wrapper" {
        for_each = each.value.should_unwrap_payload ? [1] : []
        content {
          write_metadata = true
        }
      }
    }
  }

  retry_policy {
    minimum_backoff = each.value.minimum_backoff != "" ? each.value.minimum_backoff : "6s"
    maximum_backoff = each.value.maximum_backoff != "" ? each.value.maximum_backoff : "300s"
  }

  # Dead letter policy (per-endpoint DLQ)
  dynamic "dead_letter_policy" {
    for_each = each.value.enable_dlq ? [1] : []
    content {
      dead_letter_topic     = google_pubsub_topic.dlq[each.key].id
      max_delivery_attempts = each.value.max_delivery_attempts
    }
  }

  ack_deadline_seconds = each.value.ack_deadline_seconds != 0 ? each.value.ack_deadline_seconds : var.default_ack_deadline_seconds

  depends_on = [
    google_pubsub_topic.dlq
  ]
}

# Dead Letter Queue topics (per endpoint)
resource "google_pubsub_topic" "dlq" {
  for_each = {
    for name, config in var.endpoints : name => config
    if config.enable_dlq
  }

  name    = "${var.topic_name}-${each.key}-dlq"
  project = var.project_id
}

# DLQ subscriptions (per endpoint)
resource "google_pubsub_subscription" "dlq" {
  for_each = {
    for name, config in var.endpoints : name => config
    if config.enable_dlq
  }

  name    = "${var.topic_name}-${each.key}-dlq-subscription"
  topic   = google_pubsub_topic.dlq[each.key].name
  project = var.project_id

  ack_deadline_seconds = each.value.ack_deadline_seconds != 0 ? each.value.ack_deadline_seconds : var.default_ack_deadline_seconds
}

# Service accounts for authentication (per endpoint)
resource "google_service_account" "push_auth" {
  for_each = {
    for name, config in var.endpoints : name => config
    if config.enable_authentication && config.service_account_email == ""
  }

  # Cuts the topic name and/or key depending on the length, due to 30 chars limitation for account_id
  account_id   = "${substr(var.topic_name, 0, 27 - min(length(each.key), 13) - 1)}-${substr(each.key, 0, 13)}-sa"
  display_name = "Pub/Sub Push Authentication for ${var.topic_name}-${each.key}"
  project      = var.project_id
}

// IAM bindings for Pub/Sub service account to publish unacknowledged messages to DLQ topics
resource "google_pubsub_topic_iam_member" "dead_letter_publisher_binding" {
  for_each = google_pubsub_topic.dlq
  topic    = each.value.name
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

// IAM bindings for Pub/Sub service account to acknowledge forwarded undeliverable messages
resource "google_pubsub_subscription_iam_member" "topic_subscriber_binding" {
  for_each = google_pubsub_subscription.subscriptions

  subscription = each.value.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}
