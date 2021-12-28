[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/gehoumi/terraform-google-ciscoasav-vm) [![Github tag](https://img.shields.io/github/tag/gehoumi/terraform-google-ciscoasav-vm.svg)](https://github.com/gehoumi/terraform-google-ciscoasav-vm/releases)
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



## Prerequisites and System Requirements for the ASAv and GCP

These sections describe prerequisites for using this module.

### Interface requirements:

Make sure three VPCs are available or created prior to deploy the ASAv. The VPCs network requires 3 subnets for:
- Management interface — Used to manage the ASAv (can’t be used for through traffic).
- Inside interface — Used to connect the ASAv to inside hosts.
- Outside interface — Used to connect the ASAv to the public network.

The [Google Terraform Network Module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) can be used to provision a project with the necessary VPC Networks and Subnets.

### License the ASAv.

Until you license the ASAv, it will run in degraded mode, which allows only 100 connections and throughput of 100 Kbps. [See Smart Software Licensing for the ASAv](https://www.cisco.com/c/en/us/td/docs/security/asa/asa96/configuration/general/asa-96-general-config/intro-license-smart.html).

## SSH Authentication: Use Case Examples

Functional example is included in the [examples](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples) directory, check it for further information.

**Warning** If you use username and password for the deployment, the secret data will be stored in the raw state as plain-text and the secret can be displayed in console output. I recommend using an encrypted password as explain in [basic_example_2](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples/basic_example_2)

Alternatively, you can add **public key authentication** by updating your [Day0 configuration](https://github.com/gehoumi/terraform-google-ciscoasav-vm/blob/072aa00f780c5775e1ae745e5ed70aa0752dc8df/template/initial_config.tpl#L60) before deployment. Or you can use SSH or ASDM after deployment to correct the configuration.

The following is a sample configuration for a username "admin":
```bash
username admin attributes
  ssh authentication publickey 80:3a:fc:d9:08:a9:1f:34:76:31:ed:ab:bd:3a:9e:03:14:1e:1b hashed
```
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

## Enable APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Compute Engine API: `compute.googleapis.com`
- Secret Manager API: `secretmanager.googleapis.com`

## Permissions

This module use the default service account to create ASAv instance, and create an admin account for admin user or for any automation tools who need access the ASAv.

The external SSH access to ASA management Public IP is protected by firewall rules. By default the firewall rule allow access only from the deployment workstation public IP, but you can override it with variable or hardcoded value if necessary.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.43, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.43, < 5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_password"></a> [admin\_password](#module\_admin\_password) | ./modules/secrets | n/a |
| <a name="module_enable_password"></a> [enable\_password](#module\_enable\_password) | ./modules/secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.public_default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.asav_deployment_tcp_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.vpc_outside_ingress_allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.asav_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [http_http.workstation_public_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [template_file.initial_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addresses_names"></a> [addresses\_names](#input\_addresses\_names) | List of Global IP (Public) addresses for external management and outside interfaces | `list(string)` | <pre>[<br>  "external-public-management-ip",<br>  "external-public-outside-ip"<br>]</pre> | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | ASAv administrator password | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | ASAv administrator username. Default is admin | `string` | `"admin"` | no |
| <a name="input_compute_service_url"></a> [compute\_service\_url](#input\_compute\_service\_url) | The compute service URL | `string` | `"https://www.googleapis.com/compute/v1"` | no |
| <a name="input_disk_labels"></a> [disk\_labels](#input\_disk\_labels) | Labels to be assigned to boot disk, provided as a map | `map(string)` | `{}` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Boot disk size in GB | `string` | `"10"` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Boot disk type | `string` | `"pd-standard"` | no |
| <a name="input_enable_password"></a> [enable\_password](#input\_enable\_password) | The ASAv enable password | `string` | `null` | no |
| <a name="input_inside_network"></a> [inside\_network](#input\_inside\_network) | The name of the VPC network to attach the ASAv inside interface | `string` | n/a | yes |
| <a name="input_inside_subnetwork"></a> [inside\_subnetwork](#input\_inside\_subnetwork) | The subnetwork name of the inside subnetwork | `string` | n/a | yes |
| <a name="input_inside_subnetwork_cidr"></a> [inside\_subnetwork\_cidr](#input\_inside\_subnetwork\_cidr) | The subnetwork cidr of the inside subnetwork | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Key-value map of labels to assign to the ASAv instance | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Instance type for the ASAv instance | `string` | `"n2-standard-4"` | no |
| <a name="input_mgmt_network"></a> [mgmt\_network](#input\_mgmt\_network) | The name of the VPC network to attach the ASAv mgmt interface | `string` | n/a | yes |
| <a name="input_mgmt_subnetwork"></a> [mgmt\_subnetwork](#input\_mgmt\_subnetwork) | The subnetwork name of the mgmt subnetwork | `string` | n/a | yes |
| <a name="input_mgmt_subnetwork_cidr"></a> [mgmt\_subnetwork\_cidr](#input\_mgmt\_subnetwork\_cidr) | The subnetwork cidr of the mgmt subnetwork | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The hostname to assign to the Cisco ASAv | `string` | `"ciscoasav-1"` | no |
| <a name="input_outside_network"></a> [outside\_network](#input\_outside\_network) | The name of the VPC network to attach the ASAv Outside interface | `string` | n/a | yes |
| <a name="input_outside_subnetwork"></a> [outside\_subnetwork](#input\_outside\_subnetwork) | The subnetwork name of the outside subnetwork | `string` | n/a | yes |
| <a name="input_outside_subnetwork_cidr"></a> [outside\_subnetwork\_cidr](#input\_outside\_subnetwork\_cidr) | The subnetwork cidr of the outside subnetwork | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Project to which the resources belong | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | The Project number to which the resources belong | `string` | n/a | yes |
| <a name="input_public_ip_whitelist_mgmt_access"></a> [public\_ip\_whitelist\_mgmt\_access](#input\_public\_ip\_whitelist\_mgmt\_access) | List of Public IP address to that need to manage ASAv instance. Default is your workstation public IP | `list(string)` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to construct the ASAv resources in | `string` | `"us-central1"` | no |
| <a name="input_source_image"></a> [source\_image](#input\_source\_image) | Source disk image. Defaults to the latest GCP public image for cisco asav. | `string` | `"cisco-asav-9-16-1-28"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone to construct the ASAv resources in | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asa_external_mgmt_ip"></a> [asa\_external\_mgmt\_ip](#output\_asa\_external\_mgmt\_ip) | address value create for external mgmt access |
| <a name="output_asa_external_outside_ip"></a> [asa\_external\_outside\_ip](#output\_asa\_external\_outside\_ip) | address value create for external outside |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Host name of the ASAv |
| <a name="output_workstation_public_ip"></a> [workstation\_public\_ip](#output\_workstation\_public\_ip) | Public IP of the workstation where to run the module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
