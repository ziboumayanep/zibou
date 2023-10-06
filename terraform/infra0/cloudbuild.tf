

locals {
  location            = "europe-west1"
  app_installation_id = "42100407" # id get from github.com/settings/installations/
  github_secret_id    = "github_token"
  github_user         = "ziboumima"
  # cloudbuild_service_account = "cloudbuild-sa@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_cloudbuildv2_connection" "github-connection" {
  location = local.location
  name     = "github-connection"

  github_config {
    app_installation_id = local.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/${local.github_secret_id}/versions/latest"
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
  service_account = google_service_account.cloudbuild_service_account.id
}
