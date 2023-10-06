resource "google_compute_global_address" "ip_address" {
  name       = "zibou-ip"
  ip_version = "IPV4"
}

# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location       = local.location
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name                = "zibou-cluster"
  location            = local.location
  enable_autopilot    = true
  deletion_protection = false
}

