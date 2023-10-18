
locals {
  cloudbuild_permissions = toset([
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/compute.instanceAdmin",
    "roles/cloudbuild.builds.editor",
    "roles/container.clusterAdmin", # create gke cluster
    "roles/compute.networkAdmin",   # create global ip address
    "roles/artifactregistry.admin"  # create artifact registry
  ])
}

resource "google_service_account" "cloudbuild_service_account" {
  account_id   = "cloudbuild-sa"
  display_name = "Cloudbuild Service Account"
}


resource "google_project_iam_member" "cloudbuild" {
  for_each = local.cloudbuild_permissions
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}
