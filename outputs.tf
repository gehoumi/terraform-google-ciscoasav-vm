output "hostname" {
  description = "Host name of the ASAv"
  value       = var.name
}

output "asa_external_mgmt_ip" {
  description = "address value create for external mgmt access"
  value       = module.public_address.addresses.0
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = module.public_address.addresses.1
}
