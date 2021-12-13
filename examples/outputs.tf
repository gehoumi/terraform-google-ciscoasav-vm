output "asa_external_mgmt_ip" {
  description = "address value create for external mgmt access"
  value       = module.ciscoasav.asa_external_mgmt_ip
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = module.ciscoasav.asa_external_outside_ip
}
