output "asa_external_mgmt_ip" {
  description = "address value create for external mgmt access"
  value       = module.ciscoasav.asa_external_mgmt_ip
}

output "asa_external_outside_ip" {
  description = "address value create for external outside"
  value       = module.ciscoasav.asa_external_outside_ip
}

output "gcloud_cmd_asa_admin_password" {
  # run this cli command to retrieve the asa admin password from secret manager
  value = "gcloud secrets versions access latest --secret=${module.ciscoasav.hostname}-admin-password --project=${var.project_id}"
}

output "ssh_cmd_asa_access" {
  # Wait for the vm to be ready before running SSH command or use -oConnectTimeout option
  value = "ssh admin@${module.ciscoasav.asa_external_mgmt_ip}"
}