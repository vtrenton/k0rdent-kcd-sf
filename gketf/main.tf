# 1) Enable required APIs
module "apis" {
  source     = "./modules/apis"
  project_id = var.project_id
}

# 2) Network (depends on APIs)
module "network" {
  source          = "./modules/network"
  project_id      = var.project_id
  region          = var.region
  network_name    = var.network_name
  subnet_name     = var.subnet_name
  subnet_cidr     = var.subnet_cidr
  pod_range_name  = var.pod_range_name
  pod_range_cidr  = var.pod_range_cidr
  svc_range_name  = var.svc_range_name
  svc_range_cidr  = var.svc_range_cidr

  depends_on = [module.apis] # ensure APIs are enabled before VPC/subnet
}

# 3) GKE Standard (depends on Network)
module "gke" {
  source                   = "./modules/gke_standard"
  project_id               = var.project_id
  zone                     = var.zone
  cluster_name             = var.cluster_name
  release_channel          = var.release_channel
  node_pool_name           = var.node_pool_name
  node_count               = var.node_count
  machine_type             = var.machine_type
  network_self_link        = module.network.network_self_link
  subnetwork_self_link     = module.network.subnetwork_self_link
  pod_range_name           = var.pod_range_name
  svc_range_name           = var.svc_range_name

  depends_on = [module.network] # make sure subnet & ranges exist first
}
