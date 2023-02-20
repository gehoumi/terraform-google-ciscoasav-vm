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
  description = "The Project number to which the resources belong"
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

variable "mgmt_network" {
  description = "The name of the VPC network to attach the ASAv mgmt interface"
  type        = string
}

variable "mgmt_subnetwork" {
  description = "The subnetwork name of the mgmt subnetwork"
  type        = string
}

variable "mgmt_subnetwork_cidr" {
  description = "The subnetwork cidr of the mgmt subnetwork"
  type        = string
}

variable "inside_network" {
  description = "The name of the VPC network to attach the ASAv inside interface"
  type        = string
}

variable "inside_subnetwork_cidr" {
  description = "The subnetwork cidr of the inside subnetwork"
  type        = string
}

variable "inside_subnetwork" {
  description = "The subnetwork name of the inside subnetwork"
  type        = string
}

variable "outside_network" {
  description = "The name of the VPC network to attach the ASAv Outside interface"
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

variable "addresses_names" {
  description = "List of Global IP (Public) addresses for external management and outside interfaces"
  type        = list(string)
  default = [
    "external-public-management-ip",
    "external-public-outside-ip",
  ]
}

variable "public_ip_whitelist_mgmt_access" {
  description = "List of Public IP address to that need to manage ASAv instance. Default is your workstation public IP"
  type        = list(string)
  default     = null
}

variable "gcp_private_supernet_cidr" {
  description = "The GCP private internal supernet that should be accessible by the remote anyconnect VPN clients"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpn_pool_cidr" {
  description = "The VPN Pool CIDR network to assign the remote anyconnect VPN clients"
  type        = string
  default     = "10.100.0.0/24"
}

variable "vpn_pool_reserve_start_ip" {
  description = "The number of IPs to be reserved from the start of VPN pool. Default is to reserve the 10 first IPs"
  type        = number
  default     = 10
}

variable "vpn_pool_reserve_end_ip" {
  description = "The number of IPs to be reserved from the end of VPN pool. Default is not to reserve anything from the end"
  type        = number
  default     = -2
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
}

variable "source_image" {
  description = <<EOT
  Image of the ASAv which is to be used in the project.
  GCP public URL image for cisco asav https://www.googleapis.com/compute/v1/projects/cisco-public/global/images/cisco-asav-9-xy-z
  The module has been tested with the following ASA version, other versions may or may not work correctly.
  Example: "cisco-asav-9-15-1-15"
           "cisco-asav-9-16-1-28"
           "cisco-asav-9-17-1"
           "cisco-asav-9-18-1"
EOT
  default     = "cisco-asav-9-19-1"
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
  default     = null
}

variable "enable_password" {
  description = "The ASAv enable password"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_key" {
  description = <<EOT
  The SSH public key to use to login to the instance. The maximum keysize is 2048 bits
   because ASA CLI will not allow more than 512 chars input on a single line.
   Enter only the part without spaces e.g AAAAB3NzaC1yc2EAAAAD....
EOT
  type        = string
  default     = ""
}

variable "smart_account_registration_token" {
  description = "The Smart Account registration token ID to activate the license"
  type        = string
  default     = ""
}

variable "throughput_level" {
  description = "The throughput level based on the instance size, the maximum supported vCPUs is 16"
  type        = map(string)

  default = {
    "n2-standard-4"  = "1G"
    "n2-standard-8"  = "2G"
    "n2-standard-16" = "10G"
  }

}
