variable "project_id" {
  type = string
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

# Network
variable "network_name" {
  type = string
  default = "demo-vpc"
}

variable "subnet_name" {
  type = string
  default = "demo-subnet"
}

variable "subnet_cidr" {
  type = string
  default = "10.10.0.0/20"
}

variable "pod_range_name" {
  type = string
  default = "pods-range"
}

variable "pod_range_cidr" {
  type = string
  default = "10.20.0.0/14"
}

variable "svc_range_name" {
  type = string
  default = "services-range" 
}

variable "svc_range_cidr" {
  type = string
  default = "10.30.0.0/20"
}

# GKE
variable "cluster_name" {
  type = string
  default = "demo-gke"
}

variable "release_channel" {
  type = string
  default = "REGULAR" # RAPID | REGULAR | STABLE
}

variable "node_pool_name" {
  type = string
  default = "default-pool"
}

variable "node_count" {
  type = number
  default = 3
}

variable "node_disk_gb" {
  type = number
  default = 30
}

variable "machine_type" {
  type = string
  default = "e2-standard-2"
}
