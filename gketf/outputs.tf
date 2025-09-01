output "cluster_endpoint" {
  value = module.gke.endpoint
}

output "get_credentials_command" {
  description = "Run this to configure kubectl on your laptop."
  value       = module.gke.get_credentials_command
}

output "network_self_link"    { value = module.network.network_self_link }
output "subnetwork_self_link" { value = module.network.subnetwork_self_link }
