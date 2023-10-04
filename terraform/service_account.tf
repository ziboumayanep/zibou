
locals {
  cloudbuild_permissions = var.cloudbuild ? toset([]) : ([
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer"
  ])
}
resource "google_service_account" "cloudbuild_service_account" {
  count        = var.cloudbuild ? 0 : 1
  account_id   = "cloudbuild-sa"
  display_name = "Cloudbuild Service Account"
}


resource "google_project_iam_member" "cloudbuild" {
  for_each = local.cloudbuild_permissions
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloudbuild_service_account[0].email}"
}
