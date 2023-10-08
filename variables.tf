variable "name" {
  description = "The hostname to assign to the Cisco ASAv"
  type        = string
  default     = "ciscoasav-1"
}

variable "project_id" {
  description = "The ID of the Project to which the resources belong"
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

variable "subnetwork_names" {
  description = <<-EOF
  The name of the required subnetworks, The subnetworks must below to the VPC management, inside  and outside.
  EOF
  type = object({
    mgmt    = string
    inside  = string
    outside = string
  })
  default = null
}

variable "vpc_project" {
  description = "The Host Project name where the VPC are created. if not provide the module use to 'project_id"
  type        = string
  default     = null
}

variable "public_static_ips" {
  description = "The existing public static IPs to use on the ASAv mgmt and outside interfaces. By default this module create one if undefined."
  type = object({
    mgmt    = string
    outside = string
  })
  default = null
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
  description = "The number of IPs to be reserved from the start of VPN pool. Default is not to reserve anything from start IP"
  type        = number
  default     = 1
}

variable "vpn_pool_reserve_end_ip" {
  description = "The number of IPs to be reserved from the end of VPN pool. Default is not to reserve anything from the end"
  type        = number
  default     = -2
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

variable "service_account_email" {
  description = "Email of Service Account for running instance. Default is to use google managed default service account "
  type        = string
  default     = null

}

variable "scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}


variable "source_image" {
  description = <<EOT
  Image of the ASAv which is to be used in the project.
  GCP public URL image for cisco asav https://www.googleapis.com/compute/v1/projects/cisco-public/global/images/cisco-asav-9-xy-z
  For more details regarding available cisco asav versions in the GCP, please run the following command:
  `gcloud compute images list --filter="name ~ .*cisco-asav-.*" --project cisco-public`
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
