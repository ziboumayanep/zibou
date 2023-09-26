terraform {
  backend "gcs" {
    bucket = "zibou-tf-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "zibou-399608"
  region  = "europe-west9"
}

resource "google_service_account" "service_account" {
  account_id   = "cloudbuild"
  display_name = "Service Account"
}
