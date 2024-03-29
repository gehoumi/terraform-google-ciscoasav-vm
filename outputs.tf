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
  value       = try(var.public_static_ips.mgmt, google_compute_address.public_static_ip_mgmt[0].address, null)
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = try(var.public_static_ips.outside, google_compute_address.public_static_ip_outside[0].address, null)
}

output "workstation_public_ip" {
  description = "Public IP of the workstation where to run the module"
  value       = data.http.workstation_public_ip.body
}
