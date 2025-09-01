variable "project_id"           { type = string }
variable "zone"                 { type = string }
variable "cluster_name"         { type = string }
variable "release_channel"      { type = string }
variable "node_pool_name"       { type = string }
variable "node_count"           { type = number }
variable "machine_type"         { type = string }
variable "node_disk_gb"         { type = number }

variable "network_self_link"    { type = string }
variable "subnetwork_self_link" { type = string }
variable "pod_range_name"       { type = string }
variable "svc_range_name"       { type = string }
