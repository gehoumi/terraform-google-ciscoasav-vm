output "network_name" {
  value       = var.create_vpc_network ? google_compute_network.network[0].name : ""
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = var.create_vpc_network ? google_compute_network.network[0].self_link : ""
  description = "The URI of the VPC being created"
}

output "subnetwork_name" {
  value       = var.create_vpc_network ? google_compute_subnetwork.subnetwork[0].name : ""
  description = "The name of the created subnet"
}

output "subnetwork_ip_cidr_range" {
  value       = var.create_vpc_network ? google_compute_subnetwork.subnetwork[0].ip_cidr_range : ""
  description = "The ip_cidr_range of the created subnet"
}
