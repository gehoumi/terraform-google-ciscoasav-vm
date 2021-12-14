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

  admin_password  = module.admin_password.secret_data
  enable_password = module.enable_password.secret_data

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
