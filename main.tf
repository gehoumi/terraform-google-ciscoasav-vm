/******************************************
	locals
 *****************************************/

locals {
  public_ip_whitelist_mgmt_access = var.public_ip_whitelist_mgmt_access == null ? ["${data.http.workstation_public_ip.body}/32"] : var.public_ip_whitelist_mgmt_access
  # If password is not set, use the generated password by the module secrets
  admin_password  = var.admin_password == null ? module.admin_password.secret_data : var.admin_password
  enable_password = var.enable_password == null ? module.enable_password.secret_data : var.enable_password

  # TODO: Use custom service accounts that have limited scope and permissions granted via IAM Roles.
  service_account_email = var.service_account_email == null ? "${data.google_project.project.number}-compute@developer.gserviceaccount.com" : var.service_account_email

  vpc_project         = var.vpc_project == null ? var.project_id : var.vpc_project
  compute_service_url = "https://www.googleapis.com/compute/v1"
}

/******************************************
  Workstation Public IP
 *****************************************/

# This is only to easily fetch the public IP of your
# local workstation to configure the VPC firewall rule
# for management access.
#
data "http" "workstation_public_ip" {
  url = "https://api.ipify.org"
}

/******************************************
	Secrets to create if password is not set
 *****************************************/
module "enable_password" {
  source        = "./modules/secrets"
  create_secret = var.enable_password == null

  project_id = var.project_id
  secret_id  = "${var.name}-enable-password"
}

module "admin_password" {
  source        = "./modules/secrets"
  create_secret = var.admin_password == null

  project_id = var.project_id
  secret_id  = "${var.name}-admin-password"
}


/******************************************
	data resources
 *****************************************/

data "google_project" "project" {
  project_id = var.project_id
}

data "google_compute_subnetwork" "mgmt" {
  name    = var.subnetwork_names.mgmt
  project = var.project_id
  region  = var.region
}

data "google_compute_subnetwork" "inside" {
  name    = var.subnetwork_names.inside
  project = var.project_id
  region  = var.region
}

data "google_compute_subnetwork" "outside" {
  name    = var.subnetwork_names.outside
  project = var.project_id
  region  = var.region
}


/******************************************
	data template file
 *****************************************/

locals {

  initial_config = templatefile("${path.module}/template/initial_config.tpl", {
    hostname                         = var.name
    inside_subnetwork_cidr           = data.google_compute_subnetwork.inside.ip_cidr_range
    outside_subnetwork_cidr          = data.google_compute_subnetwork.outside.ip_cidr_range
    vpn_ip_pool_start                = cidrhost(var.vpn_pool_cidr, var.vpn_pool_reserve_start_ip)
    vpn_ip_pool_end                  = cidrhost(var.vpn_pool_cidr, var.vpn_pool_reserve_end_ip)
    vpn_pool_netmask                 = cidrnetmask(var.vpn_pool_cidr)
    gcp_private_supernet_cidr        = var.gcp_private_supernet_cidr
    admin_username                   = var.admin_username
    admin_password                   = local.admin_password
    enable_password                  = local.enable_password
    ssh_key                          = var.ssh_key
    smart_account_registration_token = var.smart_account_registration_token
    throughput_level                 = lookup(var.throughput_level, var.machine_type, "1G")
  })
}


/******************************************
	BEGIN ASAv instance (VM)
 *****************************************/

resource "google_compute_instance" "asav_vm" {
  project        = var.project_id
  name           = "${var.name}-vm"
  zone           = var.zone
  can_ip_forward = true
  machine_type   = var.machine_type

  metadata = {
    "google-logging-enable"    = "true"
    "google-monitoring-enable" = "true"
    # Enabling serial port output logging
    "serial-port-logging-enable" = "true"
    # No ssh-keys here, ssh-key are supply directly by the initial_config template file
  }

  metadata_startup_script = local.initial_config
  # NOTE: Using the initial startup script is not a great way to manage the ASA configuration, because
  #       Updating will result in termination of the host
  #       Just ignore changes on the file initial_config.tpl after the initial deployment
  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }

  labels = var.labels
  tags   = [var.name]

  boot_disk {
    initialize_params {
      image  = "${local.compute_service_url}/projects/cisco-public/global/images/${var.source_image}"
      labels = var.disk_labels
      size   = var.disk_size_gb
      type   = var.disk_type
    }
  }
  # "nic0 vpc mgmt"
  network_interface {
    network    = data.google_compute_subnetwork.mgmt.network
    subnetwork = "${local.compute_service_url}/projects/${local.vpc_project}/regions/${var.region}/subnetworks/${var.subnetwork_names.mgmt}"

    access_config {
      nat_ip       = try(var.public_static_ips.mgmt, google_compute_address.public_static_ip_mgmt[0].address, null)
      network_tier = "PREMIUM"
    }

  }
  # "nic1 vpc inside"
  network_interface {
    network    = data.google_compute_subnetwork.inside.network
    subnetwork = "${local.compute_service_url}/projects/${local.vpc_project}/regions/${var.region}/subnetworks/${var.subnetwork_names.inside}"
  }
  # "nic2 vpc outside"
  network_interface {
    network    = data.google_compute_subnetwork.outside.network
    subnetwork = "${local.compute_service_url}/projects/${local.vpc_project}/regions/${var.region}/subnetworks/${var.subnetwork_names.outside}"

    access_config {
      nat_ip       = try(var.public_static_ips.outside, google_compute_address.public_static_ip_outside[0].address, null)
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
    email  = local.service_account_email
    scopes = var.scopes
  }
}

/*********************************
  BEGIN FIREWALL RULES
*********************************/

# Applied to Management VPC Network
resource "google_compute_firewall" "asav_deployment_tcp_https" {
  project       = var.project_id
  name          = "${var.name}-tcp-22-443"
  network       = data.google_compute_subnetwork.mgmt.network
  description   = "Rules to allow SSH and HTTPS connections while deploying or managing the ASAv instance"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = local.public_ip_whitelist_mgmt_access
  target_tags   = [var.name]
  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }
}

# Applied to OUTSIDE VPC Network
resource "google_compute_firewall" "vpc_outside_ingress_allow_https" {
  project     = var.project_id
  name        = "${var.name}-any-outside-tcp-udp-443"
  network     = data.google_compute_subnetwork.outside.network
  description = "Rules to allow HTTPS from anywhere"
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = [var.name]
  # UDP 443 is required by DTLS
  allow {
    protocol = "udp"
    ports    = ["443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

/******************************************
  Public IP addresses reservation, not ephemeral
 *****************************************/

resource "google_compute_address" "public_static_ip_mgmt" {
  count = var.public_static_ips == null ? 1 : 0

  name         = "${var.name}-public-mgmt-ip-${count.index}"
  address_type = "EXTERNAL"
  project      = var.project_id
  region       = var.region
}

resource "google_compute_address" "public_static_ip_outside" {
  count = var.public_static_ips == null ? 1 : 0

  name    = "${var.name}-public-outside-ip-${count.index}"
  project = var.project_id
  region  = var.region
}