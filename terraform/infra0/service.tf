locals {
  services = toset([
    "cloudbuild",
    "secretmanager",
    "iam",
    "container", # gke
    "artifactregistry"
  ])
}
resource "google_project_service" "project" {
  for_each = local.services
  project  = var.project_id
  service  = "${each.value}.googleapis.com"
}
