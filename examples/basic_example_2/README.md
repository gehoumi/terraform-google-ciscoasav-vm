# Basic Example 2

This basic example will set up 3 basics networks, subnets and Cisco ASAv instance for you to log into using SSH with your own secrets. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity we will restrict to only one Public IP. This should be scoped down to allow access from specific trusted hosts.

## Set variables

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
