# variables.tf
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
}

variable "storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "uniform_bucket_level_access" {
  description = "Enables uniform bucket-level access"
  type        = bool
  default     = true
}

variable "object_lifetime_days" {
  description = "Number of days after which objects in the bucket should be deleted. Optional."
  type        = number
  default     = null
}

variable "enable_versioning" {
  description = "Enables versioning for the bucket"
  type        = bool
  default     = false
}