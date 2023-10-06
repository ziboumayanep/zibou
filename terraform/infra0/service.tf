locals {
  services = toset(["cloudbuild", "secretmanager"])
}
resource "google_project_service" "project" {
  for_each = local.services
  project  = var.project_id
  service  = "${each.value}.googleapis.com"
}
