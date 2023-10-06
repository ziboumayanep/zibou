terraform {
  backend "gcs" {
    bucket = "ziboumima-tf-state"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0.0"
    }
  }

  required_version = ">= 0.14"
}

provider "google" {
  project = var.project_id
  region  = "europe-west1"
}
