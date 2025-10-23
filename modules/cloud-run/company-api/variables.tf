variable "location" {
  description = "The location to deploy cloud run application"
  type        = string
}

variable "app_name" {
  description = "The name of the application deployed to cloud run"
  type        = string
}

variable "image" {
  description = "Link to the docker image to run inside cloud run"
  type        = string
}

variable "project_id" {
  description = "The id of the project in which the application belongs"
  type        = string
}

variable "env_vars" {
  description = "Map of environment variables for container"
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "Number of CPUs"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory size"
  type        = string
  default     = "512Mi"
}
