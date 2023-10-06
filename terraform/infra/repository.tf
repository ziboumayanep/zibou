resource "google_artifact_registry_repository" "zibou" {
  location      = local.location
  repository_id = "zibou"
  description   = "zibou repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}
