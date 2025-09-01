output "endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --zone ${google_container_cluster.cluster.location} --project ${google_container_cluster.cluster.project}"
}

