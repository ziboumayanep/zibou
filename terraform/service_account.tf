
resource "google_service_account" "cloudbuild_service_account" {
  project      = var.project_id
  account_id   = "cloudbuild-sa"
  display_name = "Cloudbuild Service Account"
}

resource "google_project_iam_member" "cloudbuild" {
  project = var.project_id
  role    = "roles/container.developer" # cloudbuild sa needs this role to update gke
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}
resource "google_project_iam_member" "act_as" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}
