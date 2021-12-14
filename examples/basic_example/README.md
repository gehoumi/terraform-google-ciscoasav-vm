# Basic Example

This example will set up 3 basics networks, subnets and Cisco ASAv instance for you to log into using SSH. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity we will restrict to only one Public IP. This should be scoped down to allow access from specific trusted hosts.

## Variables

- Get your public IP and set the value to the variable `public_ip_whitelist_mgmt_access`

```
dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
```

- Create a `secret.tfvars` file with the two required password variable similar to:

```
admin_password  = "#insecure@password38"
enable_password = "#enable@password12338"
```
- Edit `variables.tf` to set your `project_id` and your `project_number`

## Usage

Basic usage of the module is as follows:

```hcl
module "ciscoasav" {
  source = "gehoumi/terraform-google-ciscoasav-vm"

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

  admin_password  = var.admin_password
  enable_password = var.enable_password
}
```

## Deploy


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

You should now be logged in as a admin user `cisco-asav-1#` with the prefix of `#` indicating you have logged in privilege level mode. You should also notice that the enable password is not asked, because `auto-enable` authorization configuration is done in the [initial_config.tpl](../../template)
