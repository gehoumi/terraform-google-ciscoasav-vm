
variable "project_id" {
  description = "The ID of the Project to which the resources belong"
  type        = string
  default     = "test-project"
}

variable "admin_password" {
  description = "ASAv administrator password"
  type        = string
  sensitive   = true
}

variable "enable_password" {
  description = "The ASAv enable password"
  type        = string
  sensitive   = true
}
