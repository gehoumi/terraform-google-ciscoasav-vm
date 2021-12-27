[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/gehoumi/terraform-google-ciscoasav-vm)
# Automated Cisco ASAv deployment on GCP with Terraform
[Terraform module](https://registry.terraform.io/modules/gehoumi/ciscoasav-vm/google/latest) to deploy Cisco Adaptive Security Virtual Appliance (ASAv) on Google Cloud Platform (GCP).

The [ASAv](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html) runs the same software as physical Cisco ASAs and can be deployed in the public [GCP cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects). It can then be configured as a VPN concentrator for remote access IPSec/SSL VPN's to protect cloud workloads, or can be used for IPSec site-to-site, etc.

The ASAv in this module requires a minimum of 3 interfaces. The module will deploy the ASAv in GCP with 3 interfaces and minimal configuration.

This module will:

- Create two external IP addresses for ASAv management and for the public outside network
- Create two firewall rules to allow SSH and HTTPS access to the ASA management, and to allow HTTPS from anywhere to ASAv outside interface.
- Fetch the deployment workstation public IP and add it to the IP whitelist for VPC firewall rule for the ASA management access after the deployment.
- Create a GCE managed instance to host the ASAv, with a startup script that provides the day0 configuration for the ASAv. The day0 configuration is applied during the first boot of the ASAv.
- Create passwords with Secret Manager for `enable mode` and `admin` password to be used to deploy the Cisco ASAv instance if the passwords are not set.



## Requirements

These sections describe requirements for using this module.
### Interface requirements:

Make sure three VPCs are available or created prior to deploy the ASAv. The VPCs network requires 3 subnets for:
- Management interface — Used to manage the ASAv (can’t be used for through traffic).
- Inside interface — Used to connect the ASAv to inside hosts.
- Outside interface — Used to connect the ASAv to the public network.

The [Google Terraform Network Module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) can be used to provision a project with the necessary VPC Networks and Subnets.

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The hostname to assign to the Cisco ASAv | `string` | `"ciscoasav-1"` | no |
| project\_id | The ID of the Project to which the resources belong | `string` | `""` | yes |
| project\_number | The Project number to which the resources belong | `string` | `""` | yes |
| region | The region to construct the ASAv resources in | `string` | `"us-central1"` | no |
| zone | The zone to construct the ASAv resources in | `string` | `"us-central1-a"` | no |
| mgmt\_network | The name of the VPC network to attach the ASAv mgmt interface | `string` | `""` | yes |
| mgmt\_subnetwork | The subnetwork name of the mgmt subnetwork | `string` | `""` | yes |
| mgmt\_subnetwork\_cidr | The subnetwork cidr of the mgmt subnetwork | `string` | `""` | yes |
| inside\_network | The name of the VPC network to attach the ASAv inside interface | `string` | `""` | yes |
| inside\_subnetwork | The subnetwork name of the inside subnetwork | `string` | `""` | yes |
| inside\_subnetwork\_cidr | The subnetwork cidr of the inside subnetwork | `string` | `""` | yes |
| outside\_network | The name of the VPC network to attach the ASAv outside interface | `string` | `""` | yes |
| outside\_subnetwork | The subnetwork name of the outside subnetwork | `string` | `""` | yes |
| outside\_subnetwork\_cidr | The subnetwork cidr of the outside subnetwork | `string` | `""` | yes |
| addresses\_names | List of Global IP (Public) addresses for external management and outside interfaces | `list(string))` | `["external-public-management-ip", "external-public-outside-ip"]` | no |
| public\_ip\_whitelist\_mgmt\_access | List of Public IP address to that need to manage ASAv instance. Default is your workstation public IP | `list(string)` | `null` | no |
| compute\_service\_url | The compute service URL | `string` | `"https://www.googleapis.com/compute/v1"` | no |
| labels | Key-value map of labels to assign to the ASAv instance | `map(string)` | `{}` | no |
| machine\_type | Instance type for the ASAv instance | `string` | `"n2-standard-4"` | no |
| source\_image | Source disk image. Defaults to the latest GCP public image for cisco asav. | `string` | `"cisco-asav-9-16-1-28"` | no |
| disk\_size\_gb | Boot disk size in GB | `string` | `"10"` | no |
| disk\_type | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard | `string` | `"pd-standard"` | no |
| disk\_labels | Labels to be assigned to boot disk, provided as a map | `map(string)` | `{}` | no |  
| admin\_username | ASAv administrator username. Default is admin | `string` | `admin` | no |
| admin\_password | ASAv administrator password | `string` | `null` | no |
| enable\_password | The ASAv enable password | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| hostname | Host name of the ASAv |
| asa\_external\_mgmt\_ip | address value create for external mgmt access |
| asa_external_outside_ip | address value create for external outside |
| workstation_public_ip | Public IP of the workstation where to run the module |

## Enable APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Compute Engine API: `compute.googleapis.com`
- Secret Manager API: `secretmanager.googleapis.com`


## Permissions

This module use the default service account to create ASAv instance, and create an admin account for admin user or for any automation tools who need access the ASAv.

The external SSH access to ASA management Public IP is protected by firewall rules. By default the firewall rule allow access only from the deployment workstation public IP, but you can override it with variable or hardcoded value if necessary.



## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
