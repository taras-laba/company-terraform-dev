output "topic_name" {
  description = "Full topic name for external API configuration"
  value       = google_pubsub_topic.main.id
}

output "topic_short" {
  description = "Short topic name"
  value       = google_pubsub_topic.main.name
}

output "project_number" {
  value = data.google_project.current.number
}

output "service_accounts" {
  description = "Map of push subscription names to service account emails"
  value       = { for k, v in google_service_account.push_auth : k => v.email }
}

output "subscription_names" {
  description = "Map of endpoint names to subscription names"
  value       = local.subscription_names_map
}
