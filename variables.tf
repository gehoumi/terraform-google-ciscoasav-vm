variable "name" {
  description = "The hostname to assign to the Cisco ASAv"
  type        = string
  default     = "ciscoasav-1"
}

variable "project_id" {
  description = "The ID of the Project to which the resources belong"
  type        = string
}

variable "project_number" {
  description = "The ID of the Project to which the resources belong"
  type        = string
}

variable "mgmt_network" {
  description = "The name of the VPC network to attach the ASAv mgmt interface"
  type        = string
}

variable "inside_network" {
  description = "The name of the VPC network to attach the ASAv inside interface"
  type        = string
}

variable "outside_network" {
  description = "The name of the VPC network to attach the ASAv Outside interface"
  type        = string
}


variable "mgmt_subnetwork" {
  description = "The subnetwork name of the mgmt subnetwork"
  type        = string
}

variable "inside_subnetwork" {
  description = "The subnetwork name of the inside subnetwork"
  type        = string
}

variable "outside_subnetwork" {
  description = "The subnetwork name of the outside subnetwork"
  type        = string
}

variable "outside_subnetwork_cidr" {
  description = "The subnetwork cidr of the outside subnetwork"
  type        = string
}

variable "inside_subnetwork_cidr" {
  description = "The subnetwork cidr of the inside subnetwork"
  type        = string
}

variable "mgmt_subnetwork_cidr" {
  description = "The subnetwork cidr of the mgmt subnetwork"
  type        = string
}


variable "region" {
  description = "The region to construct the ASAv resources in"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to construct the ASAv resources in"
  type        = string
  default     = "us-central1-a"
}

variable "public_ip_whitelist_mgmt_access" {
  description = "List of Public IP address to that need to manage ASAv instance. Default is from everywhere"
  default     = ["0.0.0.0/0"]
}

variable "compute_service_url" {
  type        = string
  description = "The compute service URL"
  default     = "https://www.googleapis.com/compute/v1"
}

variable "labels" {
  description = "Key-value map of labels to assign to the ASAv instance"
  type        = map(string)
  default     = {}
}

variable "machine_type" {
  type        = string
  description = "Instance type for the ASAv instance"
  default     = "n2-standard-4"
  # change to "n2-custom-2-5632" or choose other type if too a large after the deployment
}
variable "source_image" {
  description = "Source disk image. Defaults to the latest GCP public image for cisco asav."
  default     = "cisco-asav-9-16-1-28"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  default     = "10"
}

variable "disk_type" {
  description = "Boot disk type"
  default     = "pd-standard"
}

variable "disk_labels" {
  description = "Labels to be assigned to boot disk, provided as a map"
  type        = map(string)
  default     = {}
}

variable "admin_username" {
  description = "ASAv administrator username. Default is admin"
  type        = string
  default     = "admin"
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
