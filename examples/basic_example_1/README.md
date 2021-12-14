# Basic Example 1 : Generate Random passwords

This example illustrates how to use the `ciscoasav-vm` module. It will set up 3 basics networks and subnets, and generate a random password to be used to deploy the Cisco ASAv instance. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity we will restrict to only one Public IP. This should be scoped down to allow access from specific trusted hosts.

## Set variables

- Edit `variables.tf` to set your `project_id` and your `project_number`
- Get your public IP and set the value to the variable `public_ip_whitelist_mgmt_access`

```
dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
```

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

Once the secret is created, you can search for the newly created secret with something
similar to the following:

```
$ gcloud secrets versions access "latest" --secret="asav-admin-password" --project="<project-id>"

```

Once the ASAv instance is created, wait few minute and try SSH

```
ssh admin@<asa_external_mgmt_ip>
```

You should now be logged in as a admin user `cisco-asav-1#` with the prefix of `#` indicating you have logged in privilege level mode. You should also notice that the enable password is not asked, because `auto-enable` authorization configuration is done in the [initial_config.tpl](https://github.com/gehoumi/terraform-google-ciscoasav-vm/tree/main/template)
