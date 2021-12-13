
variable "project_id" {
  default = "<your_project_id>"
}

variable "project_number" {
  default = "<your_project_number>"
}

variable "public_ip_whitelist_mgmt_access" {
  default = ["<your_internet_public_ip>"]
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
