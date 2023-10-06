
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
