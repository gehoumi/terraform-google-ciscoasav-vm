[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/gehoumi/terraform-google-ciscoasav-vm)
# Terraform-google-ciscoasav-vm
Terraform module to deploy Cisco ASAv on GCP

The ASAv in this module requires a minimum of 3 interfaces. The module will deploy a Cisco ASAv in GCP with 3 interfaces.

This module will:

- Create two external IP addresses for ASAv management and for the public outside network
- Create two firewall rules to allow SSH and HTTPS access to the ASA management, and to allow HTTPS from anywhere to ASAv outside interface.
- Fetch the deployment workstation public IP and add it to the IP whitelist for VPC firewall rule for the ASA management access after the deployment.
- Create a GCE managed instance to host the ASAv, with a startup script that provides the day0 configuration for the ASAv. The day0 configuration is applied during the firstboot of the ASAv.



## Requirements

These sections describe requirements for using this module.
### Interface requirements:

Make sure three VPCs are available or created prior to deploy the ASAv. The VPCs network requires 3 subnets for:
- Management interface — Used to manage the ASAv (can’t be used for through traffic).
- Inside interface — Used to connect the ASAv to inside hosts.
- Outside interface — Used to connect the ASAv to the public network.


## Examples

Functional example is included in the [examples](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples) directory, check it for further information.

*Warning* The secret data will be stored in the raw state as plain-text and the secret can be displayed in console output. I recommend using an encrypted password as explain in [basic_example_2](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples/basic_example_2)

## Usage

Basic usage of this module is as follows:

```hcl
module "ciscoasav" {
  source = "gehoumi/ciscoasav-vm/google"

  name           = "cisco-asav-1"
  project_id     = var.project_id
  project_number = var.project_number

  mgmt_network         = local.vpc.management.network_name
  mgmt_subnetwork      = local.vpc.management.subnetwork_name
  mgmt_subnetwork_cidr = local.vpc.management.subnetwork_ip_cidr_range

  inside_network         = local.vpc.inside.network_name
  inside_subnetwork      = local.vpc.inside.subnetwork_name
  inside_subnetwork_cidr = local.vpc.inside.subnetwork_ip_cidr_range

  outside_network         = local.vpc.outside.network_name
  outside_subnetwork      = local.vpc.outside.subnetwork_name
  outside_subnetwork_cidr = local.vpc.outside.subnetwork_ip_cidr_range

}
```

### Enable APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Compute Engine API: `compute.googleapis.com`
- Secret Manager API: `secretmanager.googleapis.com`


### Permissions

This module use the default service account to create ASAv instance, and create an admin account for admin user or for any automation tools who need access the ASAv.

The external SSH access to ASA management Public IP is protected by firewall rules. By default the firewall rule allow access only from the deployment workstation public IP, but you can override it with variable or hardcoded value if necessary.



## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
