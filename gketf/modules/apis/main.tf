variable "project_id" { type = string }

resource "google_project_service" "serviceusage" {
  project = var.project_id
  service = "serviceusage.googleapis.com"

  disable_on_destroy         = false
  disable_dependent_services = true
}

locals {
  services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

resource "google_project_service" "enabled" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.key

  disable_on_destroy         = false
  disable_dependent_services = true

  depends_on = [google_project_service.serviceusage]
}

