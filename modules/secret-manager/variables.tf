variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "secret_id" {
  description = "The ID of the secret to create"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.secret_id))
    error_message = "Secret ID must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "labels" {
  description = "Labels to apply to the secret"
  type        = map(string)
  default     = {}
}