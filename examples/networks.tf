/******************************************
	VPC configuration
 *****************************************/
module "vpc_management" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = local.vpc.management.network_name

  subnets = [
    {
      subnet_name   = local.vpc.management.subnetwork_name
      subnet_ip     = local.vpc.management.subnetwork_ip_cidr_range
      subnet_region = var.default_region
    }
  ]
}

module "vpc_inside" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = local.vpc.inside.network_name

  subnets = [
    {
      subnet_name   = local.vpc.inside.subnetwork_name
      subnet_ip     = local.vpc.inside.subnetwork_ip_cidr_range
      subnet_region = var.default_region
    }
  ]
}

module "vpc_outside" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = local.vpc.outside.network_name

  subnets = [
    {
      subnet_name   = local.vpc.outside.subnetwork_name
      subnet_ip     = local.vpc.outside.subnetwork_ip_cidr_range
      subnet_region = var.default_region
    }
  ]
}
