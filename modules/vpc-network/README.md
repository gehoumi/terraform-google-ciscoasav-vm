# VPC Network Module

This submodule will:

- create a vpc network.
- create a subnet within vpc network.

## Usage

Basic usage of this submodule is as follows:

```hcl
module "admin_password" {
  source = "gehoumi/ciscoasav-vm/google//modules/secrets"

  project_id = var.project_id
  secret_id = "asav-admin-password"

}

```
