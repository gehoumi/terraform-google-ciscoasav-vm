[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/gehoumi/terraform-google-ciscoasav-vm)
# terraform-google-ciscoasav-vm
Terraform module to deploy Cisco ASAv on GCP

The ASAv requires a minimum of 3 interfaces. This module will deploy a Cisco ASAv in GCP with 3 interfaces.

This module will:

- Create two external IP addresses for ASAv management and for the public outside network
- Create two firewall rules to allow SSH and HTTPS access to the ASA management, and to allow HTTPS from anywhere to ASAv outside interface.
- Create a GCE managed instance to host the ASAv, with a startup script that provides the day0 configuration for the ASAv. The day0 configuration is applied during the firstboot of the ASAv.

## Requirements

These sections describe requirements for using this module.
### Interface requirements:
- Management interface—Used to connect the ASAv to the ASDM; can’t be used for through traffic.
- Inside interface—Used to connect the ASAv to inside hosts.
- Outside interface—Used to connect the ASAv to the public network.

The ASAv deployment requires theses three VPC networks to be created prior to deploying the ASAv.

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

  mgmt_network    = local.vpc.management.network_name
  inside_network  = local.vpc.inside.network_name
  outside_network = local.vpc.outside.network_name

  mgmt_subnetwork    = local.vpc.management.subnetwork_name
  inside_subnetwork  = local.vpc.inside.subnetwork_name
  outside_subnetwork = local.vpc.outside.subnetwork_name

  mgmt_subnetwork_cidr    = local.vpc.management.subnetwork_ip_cidr_range
  inside_subnetwork_cidr  = local.vpc.inside.subnetwork_ip_cidr_range
  outside_subnetwork_cidr = local.vpc.outside.subnetwork_ip_cidr_range

  public_ip_whitelist_mgmt_access = var.public_ip_whitelist_mgmt_access

  depends_on = [
    module.vpc_management,
    module.vpc_inside,
    module.vpc_outside,
  ]

}
```

### Enable APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Compute Engine API: `compute.googleapis.com`
- Secret Manager API: `secretmanager.googleapis.com`


### Permissions

This module use the default service account to create ASAv instance, and create an admin account for the users or any automation tools who need access the ASAv.

The external SSH access to ASA management Public IP is protected by firewall rules. By default the firewall rule allow access from anywhere, make sure to restrict access a list of your public IPs.



## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
