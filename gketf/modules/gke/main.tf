resource "google_container_cluster" "cluster" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.zone

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  # Use VPC-native (IP aliases) with the secondary ranges created in the subnet
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_range_name
    services_secondary_range_name = var.svc_range_name
  }

  # Manage node pools separately to avoid race conditions
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel { channel = var.release_channel }

  deletion_protection = false
}

resource "google_container_node_pool" "pool" {
  project  = var.project_id
  name     = var.node_pool_name
  cluster  = google_container_cluster.cluster.name
  location = var.zone

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_type = "pd-ssd"
    disk_size_gb = var.node_disk_gb
  }

  depends_on = [google_container_cluster.cluster]
}

