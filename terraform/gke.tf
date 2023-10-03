resource "google_compute_address" "ip_address" {
  name = "zibou-ip2"
}

# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location       = local.location
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name             = "zibou-cluster2"
  location         = local.location
  enable_autopilot = true
}

