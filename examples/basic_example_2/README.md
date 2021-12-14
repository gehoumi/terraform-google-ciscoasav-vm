# Basic Example 2 : Bring your own passwords

This basic example will set up 3 basics networks, subnets and Cisco ASAv instance for you to log into using SSH with your own secrets. You'll notice that the module create a firewall rule that allows SSH and HTTPS access on the ASAv management interface, for simplicity we will restrict to only one Public IP. This should be scoped down to allow access from specific trusted hosts.

## Usage

- Edit `variables.tf` to set your `project_id` and your `project_number`
- Get your public IP and set the value to the variable `public_ip_whitelist_mgmt_access`

```
dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
```

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
