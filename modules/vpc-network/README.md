# VPC Network Module

This submodule will:

- create a vpc network.
- create a subnet within vpc network.

## Usage

Basic usage of this submodule is as follows:

```hcl
module "vpc_management" {
  source = "./modules/vpc-network"

  project_id   = var.project_id
  network_name = var.mgmt_network

  subnetwork_name          = var.mgmt_subnetwork
  subnetwork_ip_cidr_range = var.mgmt_subnetwork_cidr
  subnet_region            = var.region

}

module "vpc_inside" {
  source = "./modules/vpc-network"

  project_id   = var.project_id
  network_name = var.inside_network

  subnetwork_name          = var.inside_subnetwork
  subnetwork_ip_cidr_range = var.inside_subnetwork_cidr
  subnet_region            = var.region

}

module "vpc_outside" {
  source = "./modules/vpc-network"

  project_id   = var.project_id
  network_name = var.outside_network

  subnetwork_name          = var.outside_subnetwork
  subnetwork_ip_cidr_range = var.outside_subnetwork_cidr
  subnet_region            = var.region

}


```
