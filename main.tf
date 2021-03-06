/******************************************
	locals
 *****************************************/

locals {
  public_ip_whitelist_mgmt_access = var.public_ip_whitelist_mgmt_access == null ? ["${data.http.workstation_public_ip.body}/32"] : var.public_ip_whitelist_mgmt_access
  # If password is not set, use the generated password by the module secrets
  admin_password  = var.admin_password == null ? module.admin_password.secret_data : var.admin_password
  enable_password = var.enable_password == null ? module.enable_password.secret_data : var.enable_password
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
	data template file
 *****************************************/

data "template_file" "initial_config" {
  template = file("${path.module}/template/initial_config.tpl")
  vars = {
    hostname                         = var.name
    inside_subnetwork_cidr           = var.inside_subnetwork_cidr
    outside_subnetwork_cidr          = var.outside_subnetwork_cidr
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
  }
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

  metadata_startup_script = data.template_file.initial_config.rendered
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
      image  = "${var.compute_service_url}/projects/cisco-public/global/images/${var.source_image}"
      labels = var.disk_labels
      size   = var.disk_size_gb
      type   = var.disk_type
    }
  }
  # "nic0 vpc mgmt"
  network_interface {
    network    = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.mgmt_network}"
    subnetwork = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.mgmt_subnetwork}"

    access_config {
      nat_ip       = google_compute_address.public_default[0].address
      network_tier = "PREMIUM"
    }
  }
  # "nic1 vpc inside"
  network_interface {
    network    = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.inside_network}"
    subnetwork = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.inside_subnetwork}"
  }
  # "nic2 vpc outside"
  network_interface {
    network    = "${var.compute_service_url}/projects/${var.project_id}/global/networks/${var.outside_network}"
    subnetwork = "${var.compute_service_url}/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.outside_subnetwork}"

    access_config {
      nat_ip       = google_compute_address.public_default[1].address
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
    # TODO: Use custom service accounts that have limited scope and permissions granted via IAM Roles.
    email = "${var.project_number}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }
}

/*********************************
  BEGIN FIREWALL RULES
*********************************/

# Applied to Management VPC Network
resource "google_compute_firewall" "asav_deployment_tcp_https" {
  project       = var.project_id
  name          = "${var.name}-tcp-22-443"
  network       = var.mgmt_network
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

resource "google_compute_address" "public_default" {
  count   = true ? length(var.addresses_names) : 0
  project = var.project_id
  name    = "${var.name}-${var.addresses_names[count.index]}"
}
