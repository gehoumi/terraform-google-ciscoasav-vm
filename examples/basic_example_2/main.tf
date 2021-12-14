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
      subnet_region = var.region
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
      subnet_region = var.region
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
      subnet_region = var.region
    }
  ]
}

/******************************************
	ASAv Instance
 *****************************************/

module "ciscoasav" {
  source         = "../.."
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

  depends_on = [
    module.vpc_management,
    module.vpc_inside,
    module.vpc_outside,
  ]
}
