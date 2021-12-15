/******************************************
	VPC configuration
 *****************************************/

resource "google_compute_network" "network" {
  count = var.create_vpc_network ? 1 : 0

  name                    = var.network_name
  project                 = var.project_id
  description             = var.description
  auto_create_subnetworks = false
}

/******************************************
	Subnet configuration
 *****************************************/

resource "google_compute_subnetwork" "subnetwork" {
  count = var.create_vpc_network ? 1 : 0

  project       = var.project_id
  region        = var.subnet_region
  name          = var.subnetwork_name
  ip_cidr_range = var.subnetwork_ip_cidr_range
  network       = google_compute_network.network[0].self_link
}
