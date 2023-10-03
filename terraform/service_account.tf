
resource "google_service_account" "service_account" {
  account_id   = "cloudbuild"
  display_name = "Cloudbuild Service Account"
}

resource "google_project_iam_member" "cloudbuild" {
  project = var.project_id
  role    = "roles/container.developer" # cloudbuild sa needs this role to update gke
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
