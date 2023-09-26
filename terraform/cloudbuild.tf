resource "google_cloudbuild_trigger" "cloudbuild" {
  # location = local.location
  name = "hugo-test"
  source_repo = "https://github.com/ziboumayanep"
  trigger_template {
    branch_name = "main"
    repo_name   = "https://github.com/ziboumayanep"
  }


  filename = "blog/hugo-cloudbuild/cloudbuild.yaml"
  included_files = ["blog/hugo-cloudbuild"]

}
