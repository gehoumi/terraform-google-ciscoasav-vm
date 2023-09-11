[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/gehoumi/terraform-google-ciscoasav-vm) [![Github tag](https://img.shields.io/github/tag/gehoumi/terraform-google-ciscoasav-vm.svg)](https://github.com/gehoumi/terraform-google-ciscoasav-vm/releases)
# Automated Cisco ASAv deployment on GCP with Terraform
[Terraform module](https://registry.terraform.io/modules/gehoumi/ciscoasav-vm/google/latest) to deploy Cisco Adaptive Security Virtual Appliance (ASAv) on Google Cloud Platform (GCP) for remote access IPSec/SSL VPN clients.

The [ASAv](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html) runs the same software as physical Cisco ASAs and can be deployed in the public [GCP cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects). It can then be configured as a VPN concentrator to connect to the private cloud workloads, or can be used for IPSec site-to-site, etc.

The ASAv in this module requires a minimum of 3 interfaces. The module will deploy the ASAv in GCP with 3 interfaces and minimal configuration.

This module will:

- Create two external IP addresses for ASAv management and for the public outside network
- Create two firewall rules to allow SSH and HTTPS access to the ASA management, and to allow HTTPS from anywhere to ASAv outside interface.
- Fetch the deployment workstation public IP and add it to the IP whitelist for VPC firewall rule for the ASA management access after the deployment.
- Create a GCE managed instance to host the ASAv, with a startup script that provides the day0 configuration for the ASAv. The day0 configuration is applied during the first boot of the ASAv. 
- Set DHCP IP assignment to all the interfaces in the ASA
- Nic0 is used to SSH to ASA virtual as it only supports IP forwarding
- Create passwords with Secret Manager for `enable mode` and `admin` password to be used to deploy the Cisco ASAv instance if the passwords are not set.
- Create a VPN pool in Split tunnel group for remote access VPN clients. You can then use a Cisco AnyConnect Secure Mobility Client to connect to your GCP private Cloud network.
- Enable SSH on the managment interface in ASA configuration



## Prerequisites and System Requirements for the ASAv and GCP

These sections describe prerequisites for using this module.

### Interface requirements:

Make sure three VPCs are available or created prior to deploy the ASAv. The VPCs network requires 3 subnets for:
- Management interface — Used to manage the ASAv (can’t be used for through traffic).
- Inside interface — Used to connect the ASAv to inside hosts.
- Outside interface — Used to connect the ASAv to the public network.

The [Google Terraform Network Module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) can be used to provision a project with the necessary VPC Networks and Subnets.

### License the ASAv:

Until you license the ASAv, it will run in degraded mode, which allows only 100 connections and throughput of 100 Kbps. You can activate the license anytime [See Smart Software Licensing for the ASAv](https://www.cisco.com/c/en/us/td/docs/security/asa/asa96/configuration/general/asa-96-general-config/intro-license-smart.html).



## Use Case Examples

Functional examples are included in the [examples](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples) directory, check it for further information.  

**Warning** If you use username and password for the deployment, the secret data will be stored in the raw state as plain-text and the secret can be displayed in console output. I recommend using an encrypted password as explain in [basic_example_2](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples/basic_example_2)

**Limitation** ASA CLI will not allow more than 512 chars input on a single line, therefore If the public key is longer than 2048 bits, you can not use the variable `ssh_key` to enter the public key in day0 configuration because it is too long. If you do so, the module will create the ASA, with `admin_password` but `ssh_key authentication` won't work and you will see this error in the ASAv [serial console](https://cloud.google.com/compute/docs/troubleshooting/troubleshooting-using-serial-console) :
```
Input line size exceeded available buffer (511 characters). First 511 chars of the line:
  ssh authentication publickey
```

Alternatively:
- you can add your **public key** after the deployment in CLI, because the IOS got around the single line by using multi-line input for the key.

The following is a sample configuration for a username "admin":
```bash
username admin attributes
  ssh authentication publickey <PUBLIC_KEY>
```
- you can also edit the day0 configuration to add your publickey hashed and append the `hashed` tag

```bash
username admin attributes
  ssh authentication publickey <PUBLIC_KEY_HASHED> hashed
```

## Usage

Basic usage of this module is as follows :

```hcl
module "ciscoasav" {
  source         = "gehoumi/ciscoasav-vm/google"
  version        = "1.0.7"
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
## SSH access 
As explain in [basic_example_1](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/examples/basic_example_1), you can search for the newly created secret in the console or use the commands in `terraform output` to retrieve the ASA admin password. Something
similar to the following:

```
$ gcloud secrets versions access latest --secret=<asa_hostname>-admin-password --project=<project-id>

```

## Connect to VPN with Cisco AnyConnect Secure Mobility Client

This section assumes that you have Cisco AnyConnect Secure Mobility Client downloaded and installed on your local Windows workstation.
- Launch the Cisco AnyConnect Secure Mobility Client and add the value of the terraform `output` IP address `asa_external_outside_ip`
- CISCO AnyConnect window will pop up stating that the ``"Untrusted VPN Server Blocked!"`` this is normal in the because the SSL certificate is untrusted. Simply select Connect Anyway
- Change the Setting by unchecking the box labeled `Block connections to untrusted servers`
- Reconnect to the VPN via CISCO AnyConnect with the user admin/password

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
| <a name="provider_google"></a> [google](#provider\_google) | 4.53.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_password"></a> [admin\_password](#module\_admin\_password) | ./modules/secrets | n/a |
| <a name="module_enable_password"></a> [enable\_password](#module\_enable\_password) | ./modules/secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.public_static_ip_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.public_static_ip_outside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.asav_deployment_tcp_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.vpc_outside_ingress_allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.asav_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_subnetwork.inside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_subnetwork.mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_subnetwork.outside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [http_http.workstation_public_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | ASAv administrator password | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | ASAv administrator username. Default is admin | `string` | `"admin"` | no |
| <a name="input_disk_labels"></a> [disk\_labels](#input\_disk\_labels) | Labels to be assigned to boot disk, provided as a map | `map(string)` | `{}` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Boot disk size in GB | `string` | `"10"` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Boot disk type | `string` | `"pd-standard"` | no |
| <a name="input_enable_password"></a> [enable\_password](#input\_enable\_password) | The ASAv enable password | `string` | `null` | no |
| <a name="input_gcp_private_supernet_cidr"></a> [gcp\_private\_supernet\_cidr](#input\_gcp\_private\_supernet\_cidr) | The GCP private internal supernet that should be accessible by the remote anyconnect VPN clients | `string` | `"10.0.0.0/8"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Key-value map of labels to assign to the ASAv instance | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Instance type for the ASAv instance | `string` | `"n2-standard-4"` | no |
| <a name="input_name"></a> [name](#input\_name) | The hostname to assign to the Cisco ASAv | `string` | `"ciscoasav-1"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Project to which the resources belong | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | The Project number to which the resources belong | `string` | n/a | yes |
| <a name="input_public_ip_whitelist_mgmt_access"></a> [public\_ip\_whitelist\_mgmt\_access](#input\_public\_ip\_whitelist\_mgmt\_access) | List of Public IP address to that need to manage ASAv instance. Default is your workstation public IP | `list(string)` | `null` | no |
| <a name="input_public_static_ips"></a> [public\_static\_ips](#input\_public\_static\_ips) | The existing public static IPs to use on the ASAv mgmt and outside interfaces. By default this module create one if undefined. | <pre>object({<br>    mgmt    = string<br>    outside = string<br>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to construct the ASAv resources in | `string` | `"us-central1"` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email of Service Account for running instance. Default is to use google managed service account | `string` | `null` | no |
| <a name="input_smart_account_registration_token"></a> [smart\_account\_registration\_token](#input\_smart\_account\_registration\_token) | The Smart Account registration token ID to activate the license | `string` | `""` | no |
| <a name="input_source_image"></a> [source\_image](#input\_source\_image) | Image of the ASAv which is to be used in the project.<br>  GCP public URL image for cisco asav https://www.googleapis.com/compute/v1/projects/cisco-public/global/images/cisco-asav-9-xy-z<br>  For more details regarding available cisco asav versions in the GCP, please run the following command:<br>  `gcloud compute images list --filter="name ~ .*cisco-asav-.*" --project cisco-public`<br>  The module has been tested with the following ASA version, other versions may or may not work correctly.<br>  Example: "cisco-asav-9-15-1-15"<br>           "cisco-asav-9-16-1-28"<br>           "cisco-asav-9-17-1"<br>           "cisco-asav-9-18-1" | `string` | `"cisco-asav-9-19-1"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The SSH public key to use to login to the instance. The maximum keysize is 2048 bits<br>   because ASA CLI will not allow more than 512 chars input on a single line.<br>   Enter only the part without spaces e.g AAAAB3NzaC1yc2EAAAAD.... | `string` | `""` | no |
| <a name="input_subnetwork_names"></a> [subnetwork\_names](#input\_subnetwork\_names) | The name of the required subnetworks, The subnetworks must below to the VPC management, inside  and outside. | <pre>object({<br>    mgmt    = string<br>    inside  = string<br>    outside = string<br>  })</pre> | `null` | no |
| <a name="input_throughput_level"></a> [throughput\_level](#input\_throughput\_level) | The throughput level based on the instance size, the maximum supported vCPUs is 16 | `map(string)` | <pre>{<br>  "n2-standard-16": "10G",<br>  "n2-standard-4": "1G",<br>  "n2-standard-8": "2G"<br>}</pre> | no |
| <a name="input_vpc_project"></a> [vpc\_project](#input\_vpc\_project) | The Host Project name where the VPC are created. if not provide the module use to 'project\_id | `string` | `null` | no |
| <a name="input_vpn_pool_cidr"></a> [vpn\_pool\_cidr](#input\_vpn\_pool\_cidr) | The VPN Pool CIDR network to assign the remote anyconnect VPN clients | `string` | `"10.100.0.0/24"` | no |
| <a name="input_vpn_pool_reserve_end_ip"></a> [vpn\_pool\_reserve\_end\_ip](#input\_vpn\_pool\_reserve\_end\_ip) | The number of IPs to be reserved from the end of VPN pool. Default is not to reserve anything from the end | `number` | `-2` | no |
| <a name="input_vpn_pool_reserve_start_ip"></a> [vpn\_pool\_reserve\_start\_ip](#input\_vpn\_pool\_reserve\_start\_ip) | The number of IPs to be reserved from the start of VPN pool. Default is not to reserve anything from start IP | `number` | `1` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone to construct the ASAv resources in | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | ASAv administrator password |
| <a name="output_asa_external_mgmt_ip"></a> [asa\_external\_mgmt\_ip](#output\_asa\_external\_mgmt\_ip) | address value create for external mgmt access |
| <a name="output_asa_external_outside_ip"></a> [asa\_external\_outside\_ip](#output\_asa\_external\_outside\_ip) | address value create for external outside |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Host name of the ASAv |
| <a name="output_workstation_public_ip"></a> [workstation\_public\_ip](#output\_workstation\_public\_ip) | Public IP of the workstation where to run the module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [Cisco ASAv Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa916/asav/getting-started/asav-916-gsg/asav_gcp.html)
- [ASA Release notes](https://www.cisco.com/c/en/us/support/security/adaptive-security-appliance-asa-software/products-release-notes-list.html)
- [terraform-google-modules/terraform-google-vm](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)
