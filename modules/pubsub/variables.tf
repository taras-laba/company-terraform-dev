variable "topic_name" {
  description = "Name of the Pub/Sub topic"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "default_ack_deadline_seconds" {
  description = "Default acknowledgment deadline in seconds"
  type        = number
  default     = 600
}

variable "endpoints" {
  description = "Map of endpoint configurations"
  type = map(object({
    push_endpoint           = string
    enable_push             = optional(bool, true)
    enable_authentication   = optional(bool, true)
    service_account_email   = optional(string, "")
    audience                = optional(string, "")
    should_unwrap_payload   = optional(bool, true)
    enable_dlq              = optional(bool, true)
    max_delivery_attempts   = optional(number, 5)
    minimum_backoff         = optional(string, "5s")
    maximum_backoff         = optional(string, "300s")
    ack_deadline_seconds    = optional(number, 0)  # 0 means use default_ack_deadline_seconds
    is_fifo                 = optional(bool, false)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for endpoint in var.endpoints : 
      endpoint.max_delivery_attempts >= 5 && endpoint.max_delivery_attempts <= 100
      if endpoint.enable_dlq
    ])
    error_message = "max_delivery_attempts must be between 5 and 100 when DLQ is enabled."
  }
  
  validation {
    condition = alltrue([
      for endpoint in var.endpoints : 
      endpoint.push_endpoint != ""
      if endpoint.enable_push
    ])
    error_message = "push_endpoint cannot be empty when enable_push is true."
  }
}
