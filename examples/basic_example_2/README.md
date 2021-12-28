# Basic Example 2 : Bring your own passwords

This basic example will set up 3 basics networks, subnets and Cisco ASAv instance for you to log into using SSH with your own secrets. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity the module will fetch your workstation public IP and add it to the IP whitelist for the management access. This was scoped down to allow access from your specific trusted hosts.

## Usage

- Edit `variables.tf` to set your `project_id` and your `project_number`

### Encrypted passwords

Because the passwords can be displayed during terraform/plan/apply, I recommend using an encrypted password.
The passwords are saved in Cisco ASA in encrypted form using a strong `pbkdf2` algorithm.
You can grab the encrypted passwords from any running Cisco ASA with CLI command `more system:running-config`.

Then set the variables `admin_password` and `enable_password` similar to:

```
variable "admin_password" {
  description = "ASAv administrator password"
  default = "$sha512$5000$yqmMJFjU5nRLhuth7Do8ag==$xvGO5EcNZvhpaDWj+YifHQ== pbkdf2"
}

variable "enable_password" {
  description = "The ASAv enable password"
  default = "$sha512$5000$MMcvuiLQEmF3d/HU8wQnrA==$LP6l9BIUHTROUfTFA5cymQ== pbkdf2"
}

```
Run the plan

```
terraform plan
```

Run the apply

```
terraform apply
```

### Plaintext passwords

If you want to use plaintext passwords:
- Create a `secret.tfvars` file with the two required passwords variable similar to:

```
admin_password  = "#insecure@password38"
enable_password = "#enable@password12338"
```
Make sure this file is not checkout by Git.

Run the plan

```
terraform plan -var-file secret.tfvars
```

Run the apply

```
terraform apply -var-file secret.tfvars
```

## CLI Usage

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
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | ASAv administrator password | `string` | n/a | yes |
| <a name="input_enable_password"></a> [enable\_password](#input\_enable\_password) | The ASAv enable password | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Project to which the resources belong | `string` | `""` | no |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | The Project number to which the resources belong | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to construct the ASAv resources in | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asa_external_mgmt_ip"></a> [asa\_external\_mgmt\_ip](#output\_asa\_external\_mgmt\_ip) | address value create for external mgmt access |
| <a name="output_asa_external_outside_ip"></a> [asa\_external\_outside\_ip](#output\_asa\_external\_outside\_ip) | address value create for external outside |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
