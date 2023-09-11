# Basic Example 1 : Generate Random passwords

This example illustrates how to use the `ciscoasav-vm` module. It will set up 3 basics networks and subnets, and generate a random password to be used to deploy the Cisco ASAv instance. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity the module will fetch your workstation public IP and add it to the IP whitelist for the management access. This was scoped down to allow access from your specific trusted hosts.

## Set variables

- Edit `variables.tf` to set your `project_id` and your `project_number`

## Usage

Run the plan

```
terraform plan
```

Run the apply

```
terraform apply
```

## CLI Usage

Once the terraform apply is completed, you can search for the newly created secret in the console or use the commands in `terraform output` to retrieve the ASA admin password. Something
similar to the following:

```
$ gcloud secrets versions access latest --secret=<asa_hostname>-admin-password --project=<project-id>

```

Once the ASAv instance is created, wait few minute and try SSH

```
ssh admin@<asa_external_mgmt_ip>
```

You should now be logged in as a admin user `cisco-asav-1#` with the prefix of `#` indicating you have logged in privilege level mode. You should also notice that the enable password is not asked, because `auto-enable` authorization configuration is done in the [initial_config.tpl](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/template)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ciscoasav"></a> [ciscoasav](#module\_ciscoasav) | ../.. | n/a |
| <a name="module_vpc_inside"></a> [vpc\_inside](#module\_vpc\_inside) | terraform-google-modules/network/google | ~> 3.0 |
| <a name="module_vpc_management"></a> [vpc\_management](#module\_vpc\_management) | terraform-google-modules/network/google | ~> 3.0 |
| <a name="module_vpc_outside"></a> [vpc\_outside](#module\_vpc\_outside) | terraform-google-modules/network/google | ~> 3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Project to which the resources belong | `string` | `"test-project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asa_external_mgmt_ip"></a> [asa\_external\_mgmt\_ip](#output\_asa\_external\_mgmt\_ip) | address value create for external mgmt access |
| <a name="output_asa_external_outside_ip"></a> [asa\_external\_outside\_ip](#output\_asa\_external\_outside\_ip) | address value create for external outside |
| <a name="output_gcloud_cmd_asa_admin_password"></a> [gcloud\_cmd\_asa\_admin\_password](#output\_gcloud\_cmd\_asa\_admin\_password) | n/a |
| <a name="output_ssh_cmd_asa_access"></a> [ssh\_cmd\_asa\_access](#output\_ssh\_cmd\_asa\_access) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
