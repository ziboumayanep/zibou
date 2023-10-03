terraform {
  backend "gcs" {
    bucket = "zibou-tf-state"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0.0"
    }
  }

  required_version = ">=1.5.7"
}

provider "google" {
  project = "zibou-399608"
  region  = "europe-west9"
}

resource "google_service_account" "service_account" {
  account_id   = "cloudbuild"
  display_name = "Service Account"
}

resource "google_compute_global_address" "zibou" {
  name = "zibou-ip2"
}
