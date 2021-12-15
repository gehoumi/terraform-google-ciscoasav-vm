variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = ""
}

variable "network_name" {
  description = "The name of the network being created"
}

variable "subnetwork_name" {
  description = "The name of the subnetwork being created"
}

variable "subnetwork_ip_cidr_range" {
  description = "The ip_cidr_range of the subnetwork being created"
}

variable "subnet_region" {
  description = "The Subnet region being created"
  type        = string
  default     = "us-central1"
}

variable "create_vpc_network" {
  description = "If the VPC network should be created"
  type        = bool
  default     = true
}
