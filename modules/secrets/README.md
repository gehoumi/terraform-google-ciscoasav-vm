# secrets

This module will:

- create a random password, the result is treated as sensitive.
- create google secret manager and secret version to store the secret data.

*Warning* The secret data will be stored in the raw state as plain-text and the secret can be displayed in console output.

## Usage

Basic usage of this module is as follows:

```hcl
module "admin_password" {
  source = "gehoumi/terraform-google-ciscoasav-vm//modules/secrets"

  project_id = var.project_id
  secret_id = "asav-admin-password"

}

```

Once the secret is created, you can search for the newly created secret with something
similar to the following:

```
$ gcloud secrets versions access "latest" --secret="asav-admin-password" --project="<project-id>"

```

## Enable APIs

A project with the following API enabled must be used to host the resources of this module:

- Secret Manager API: `secretmanager.googleapis.com`
