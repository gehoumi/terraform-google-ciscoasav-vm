output "hostname" {
  description = "Host name of the ASAv"
  value       = var.name
}

output "admin_password" {
  description = "ASAv administrator password"
  value       = module.admin_password.secret_data
  sensitive   = true
}

output "asa_external_mgmt_ip" {
  description = "address value create for external mgmt access"
  value       = google_compute_address.public_default[0].address
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = google_compute_address.public_default[1].address
}

output "workstation_public_ip" {
  description = "Public IP of the workstation where to run the module"
  value       = data.http.workstation_public_ip.body
}
