

locals {
  location            = "europe-west1"
  app_installation_id = "42100407" # id get from github.com/settings/installations/
  #   github_secret_id    = "github_token"
  github_user = "ziboumima"
}

resource "google_secret_manager_secret" "github_token" {
  secret_id = "github_token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_token_data
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_cloudbuildv2_connection" "github-connection" {
  location = local.location
  name     = "github-connection"

  github_config {
    app_installation_id = local.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/${google_secret_manager_secret.github_token.secret_id}/versions/latest"
    }
  }
}

resource "google_cloudbuildv2_repository" "zibou-repository" {
  name              = "zibou"
  parent_connection = google_cloudbuildv2_connection.github-connection.id
  remote_uri        = "https://github.com/${local.github_user}/zibou.git"
}

// create the cloudbuild trigger to execute this file
resource "google_cloudbuild_trigger" "iac" {
  location = local.location
  name     = "iac"

  repository_event_config {
    repository = google_cloudbuildv2_repository.zibou-repository.id
    push {
      branch = "main"
    }
  }
  filename        = "terraform/infra/cloudbuild.yaml"
  included_files  = ["terraform/infra/**"]
  ignored_files   = ["blog/**"]
  service_account = google_service_account.cloudbuild_service_account.id
}
