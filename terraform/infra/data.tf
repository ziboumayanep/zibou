data "google_service_account" "service_account" {
  account_id = "cloudbuild-sa"
}

data "terraform_remote_state" "infra0" {
  backend = "gcs"
  config = {
    bucket = "zibou-tf-state"
    prefix = "terraform/state0"
  }
}
