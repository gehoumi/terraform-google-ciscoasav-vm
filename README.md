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

Functional example is included in the [examples](./examples/) directory, check it for further information.

## Usage

Basic usage of this module is as follows:

```hcl
module "ciscoasav" {
  source = "../../modules/terraform-google-ciscoasav-vm"
  name   = "cisco-asav-1"
  project_id     = var.project_id
  project_number = "<PROJECT ID>"

  mgmt_network    = "<MGMT NETWORK NAME>"
  inside_network  = "<INSIDE NETWORK NAME>"
  outside_network = "<OUTSIDE NETWORK NAME>"

  mgmt_subnetwork    = "<MGMT SUBNETWORK NAME>"
  inside_subnetwork  = "<INSIDE SUBNETWORK NAME>"
  outside_subnetwork = "<OUTSIDE SUBNETWORK NAME>"

  mgmt_subnetwork_cidr    = "<MGMT SUBNETWORK CIDR>"
  inside_subnetwork_cidr  = "<INSIDE SUBNETWORK CIDR>"
  outside_subnetwork_cidr = "<OUTSIDE SUBNETWORK CIDR>"

  admin_password  = var.admin_password
  enable_password = var.enable_password

}
```

### Enable APIs

A project with the following API enabled must be used to host the
resources of this module:

- Compute Engine API: `compute.googleapis.com`


### Permissions

This module use the default service account to create ASAv instance, and create an admin account for the users or any automation tools who need access the ASAv.

The external SSH access to ASA management Public IP is protected by firewall rules. By default the firewall rule allow access from anywhere, make sure to restrict access a list of your public IPs.



## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
