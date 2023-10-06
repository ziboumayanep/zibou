
resource "google_cloudbuild_trigger" "hugo-build-image" {
  location = local.location
  name     = "hugo-build-image"

  repository_event_config {
    repository = data.terraform_remote_state.infra0.outputs.repository_id
    push {
      branch = "main"
    }
  }
  filename        = "blog/hugo-cloudbuild/cloudbuild.yaml"
  included_files  = ["blog/hugo-cloudbuild/**"]
  service_account = data.google_service_account.service_account.id
}

resource "google_cloudbuild_trigger" "blog" {
  location = local.location
  name     = "blog"

  repository_event_config {
    repository = data.terraform_remote_state.infra0.outputs.repository_id
    push {
      branch = "main"
    }
  }
  filename       = "blog/cloudbuild.yaml"
  included_files = ["blog/**"]

  service_account = data.google_service_account.service_account.id
}
