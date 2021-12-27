output "hostname" {
  description = "Host name of the ASAv"
  value       = var.name
}

output "asa_external_mgmt_ip" {
  description = "address value create for external mgmt access"
  value       = google_compute_address.public_default[0].address
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = google_compute_address.public_default[1].address
}

output "your_workstation_public_ip" {
  value = data.http.workstation_public_ip.body
}
