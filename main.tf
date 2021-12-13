locals {
  # Interface IPs by default are the third IP address on the subnetwork CIDR
  # The first 2 IPs addresses are reserved and used by GCP
  mgmt_interface_ip_address    = cidrhost(var.mgmt_subnetwork_cidr, 3)
  inside_interface_ip_address  = cidrhost(var.inside_subnetwork_cidr, 3)
  outside_interface_ip_address = cidrhost(var.outside_subnetwork_cidr, 3)
}

data "template_file" "initial_config" {
  template = file("${path.module}/template/initial_config.tpl")
  vars = {
    hostname                     = var.name
    inside_interface_ip_address  = local.inside_interface_ip_address
    outside_interface_ip_address = local.outside_interface_ip_address
    inside_subnetwork_cidr       = var.inside_subnetwork_cidr
    outside_subnetwork_cidr      = var.outside_subnetwork_cidr

    admin_username  = var.admin_username
    admin_password  = var.admin_password
    enable_password = var.enable_password
  }
}

/**********************************************/
/***** BEGIN ASAv instance (VM)          ******/
/**********************************************/
// Resources below are reproduced from deployment manager by launching an ASAv instance
// using the Cisco ASA virtual firewall (ASAv) offering on the GCP Marketplace.
// https://console.cloud.google.com/marketplace/product/cisco-public/cisco-asav-byol
resource "google_compute_instance" "asav_vm" {
  project = var.project_id
  name    = "${var.name}-vm"
  zone    = var.zone

  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false

  machine_type = var.machine_type

  metadata = {
    "google-logging-enable"    = "true"
    "google-monitoring-enable" = "true"
    # Enabling serial port output logging
    "serial-port-logging-enable" = "true"
    # No ssh-keys here, ssh-key are supply directly by the initial_config template file
  }

  metadata_startup_script = data.template_file.initial_config.rendered
  # NOTE: Using the initial startup script is not a great way to manage the ASA configuration, because
  #       Updating will result in termination of the host - this is specifically ignored as it
  #       is too dangerous and termination/changes should be done with purpose/intentionally.
  #       Use SSH, ASDM, or ciscoasa terraform provider to manage the cisco ASAv, and update the initial script.
  lifecycle {
    ignore_changes = [
      #metadata_startup_script,
    ]
  }

  #labels = var.labels
  tags = [var.name]

  boot_disk {
    initialize_params {
      # Get the latest cisco IOS from GCP Marketplace deployment page
      image  = "${var.compute_service_url}/projects/cisco-public/global/images/${var.source_image}"
      labels = var.disk_labels
      size   = var.disk_size_gb
      type   = var.disk_type
    }
  }

  network_interface {
    # "nic0 vpc-mgmt-1"
    network            = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.mgmt_network}"
    network_ip         = local.mgmt_interface_ip_address
    subnetwork         = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.mgmt_subnetwork}"
    subnetwork_project = var.project_id

    access_config {
      nat_ip       = module.public_address.addresses.0
      network_tier = "PREMIUM"
    }
  }
  network_interface {
    # "nic1 vpc-inside-1"
    network            = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.inside_network}"
    network_ip         = local.inside_interface_ip_address
    subnetwork         = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.inside_subnetwork}"
    subnetwork_project = var.project_id
  }
  network_interface {
    # "nic2 vpc-outside-1"
    network            = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.outside_network}"
    network_ip         = local.outside_interface_ip_address
    subnetwork         = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.outside_subnetwork}"
    subnetwork_project = var.project_id

    access_config {
      nat_ip       = module.public_address.addresses.1
      network_tier = "PREMIUM"
    }
  }

  scheduling {
    automatic_restart   = true
    min_node_cpus       = 0
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email = "${var.project_number}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  timeouts {}
}


/*********************************/
/***** BEGIN FIREWALL RULES ******/
/*********************************/

# Applied to Management VPC Network
resource "google_compute_firewall" "asav_deployment_tcp_https" {
  project       = var.project_id
  name          = "${var.name}-tcp-22-443"
  network       = var.mgmt_network
  description   = "Rules to allow SSH and HTTPS connections while deploying or managing the ASAv instance"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.public_ip_whitelist_mgmt_access
  target_tags   = [var.name]
  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }
}

# Applied to OUTSIDE VPC Network
resource "google_compute_firewall" "vpc_outside_ingress_allow_https" {
  project     = var.project_id
  name        = "${var.name}-any-outside-tcp-443"
  network     = var.outside_network
  description = "Rules to allow HTTPS from anywhere"
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = [var.name]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

/******************************************
  IP address reservation
 *****************************************/
module "public_address" {
  source       = "terraform-google-modules/address/google"
  version      = "3.0.0"
  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  names = [
    "external-public-management-ip",
    "external-public-outside-ip",
  ]
}
