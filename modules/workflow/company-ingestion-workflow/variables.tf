variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location to deploy cloud run application"
  type        = string
}

variable "carrier_sync_init_job_name" {
  description = "The name of the Cloud Run Job for carrier sync initialization"
  type        = string
}

variable "carrier_sync_worker_job_name" {
  description = "The name of the Cloud Run Job for carrier sync worker"
  type        = string
}

variable "carrier_registration_subscription_name" {
  description = "The name of the Pub/Sub subscription for carrier registration updates"
  type        = string
}

variable "enable_log_debugging" {
  description = "Flag to enable or disable detailed logging for the workflow"
  type        = bool
  default     = false
}