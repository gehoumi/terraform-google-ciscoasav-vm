variable "project_id" {
  description = "The ID of the Project to which the resources belong"
  type        = string
}

variable "secret_id" {
  description = "The secret ID, must be unique within the project."
}

variable "replicas_location_1" {
  description = "The canonical IDs of the location to replicate data"
  type        = string
  default     = "us-central1"
}

variable "replicas_location_2" {
  description = "The canonical IDs of the location to replicate data"
  type        = string
  default     = "us-east1"
}

variable "label" {
  description = "label of the secret"
  default     = "created_by_terraform"
}

variable "create_secret" {
  description = "If the secret should be created"
  type        = bool
  default     = true
}
