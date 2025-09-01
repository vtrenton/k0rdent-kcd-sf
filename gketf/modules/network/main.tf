resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  secondary_ip_range {
    range_name    = var.pod_range_name
    ip_cidr_range = var.pod_range_cidr
  }
  secondary_ip_range {
    range_name    = var.svc_range_name
    ip_cidr_range = var.svc_range_cidr
  }
}

