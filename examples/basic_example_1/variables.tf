
variable "project_id" {
  description = "The ID of the Project to which the resources belong"
  type        = string
  default     = ""
}


variable "project_number" {
  description = "The Project number to which the resources belong"
  type        = string
  default     = ""
}

variable "public_ip_whitelist_mgmt_access" {
  default = [""]
}

variable "region" {
  description = "The region to construct the ASAv resources in"
  type        = string
  default     = "us-central1"
}


locals {
  vpc = {
    management = {
      network_name             = "${var.project_id}-vpc-mgmt-1"
      subnetwork_name          = "${var.project_id}-mgmt-subnet-01"
      subnetwork_ip_cidr_range = "10.10.10.0/24"
    },
    inside = {
      network_name             = "${var.project_id}-vpc-inside-1"
      subnetwork_name          = "${var.project_id}-inside-subnet-01"
      subnetwork_ip_cidr_range = "10.10.20.0/24"
    },
    outside = {
      network_name             = "${var.project_id}-vpc-outside-1"
      subnetwork_name          = "${var.project_id}-outside-subnet-01"
      subnetwork_ip_cidr_range = "10.10.30.0/24"
    }
  }
}
