variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "us-central1"
}

variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "schedule" {
  type    = string
  default = "0 5 * * *" # daily at 5am
}

variable "time_zone" {
  type    = string
  default = "UTC"
}

variable "timeout" {
  type    = string
  default = "86400s"
}

variable "env_vars" {
  description = "Map of environment variables for container"
  type        = map(string)
  default     = {}
}

variable "gcs_volumes" {
  description = "Map of volumes to mount into the container"
  type = map(object({
    bucket      = string
    read_only   = optional(bool, false)
    mount_paths = list(string)
  }))
  default = {}
}

variable "pubsub_topic_names" {
  description = "List of topic names to give access to"
  type        = list(string)
  default     = []
}

variable "secretIds" {
  description = "List of Secret Manager secret IDs to give access to"
  type        = list(string)
  default     = []
}
