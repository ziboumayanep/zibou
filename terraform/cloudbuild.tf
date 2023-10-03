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

resource "google_cloudbuild_trigger" "hugo-build-image" {
  location = local.location
  name     = "hugo-build-image"

  repository_event_config {
    repository = google_cloudbuildv2_repository.zibou-repository.id
    push {
      branch = "main"
    }
  }
  filename        = "blog/hugo-cloudbuild/cloudbuild.yaml"
  included_files  = ["blog/hugo-cloudbuild/**"]
  service_account = google_service_account.service_account.id
  logging         = "CLOUD_LOGGING_ONLY"
}

resource "google_cloudbuild_trigger" "blog" {
  location = local.location
  name     = "blog"

  repository_event_config {
    repository = google_cloudbuildv2_repository.zibou-repository.id
    push {
      branch = "main"
    }
  }
  filename       = "blog/cloudbuild.yaml"
  included_files = ["blog/**"]

  service_account = google_service_account.service_account.id
  logging         = "CLOUD_LOGGING_ONLY"
}
