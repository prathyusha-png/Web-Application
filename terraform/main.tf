provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create VPC and subnetwork (simple)  
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Artifact Registry (Docker repo)
resource "google_artifact_registry_repository" "repo" {
  provider = google
  location     = var.artifact_repo_location
  repository_id = "hello-app-repo"
  description  = "Artifact Registry for hello app"
  format       = "DOCKER"
}

# GKE cluster (basic, not autopilot)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  remove_default_node_pool = true
  initial_node_count = 1

  ip_allocation_policy {}
  # enable necessary addons if desired
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# Optionally enable the Kubernetes Engine API & Artifact Registry API - these usually must be enabled beforehand.
# (You can enable via console or gcloud. See README.)

output "artifact_repo" {
  value = google_artifact_registry_repository.repo.repository_id
}

output "artifact_repo_location" {
  value = google_artifact_registry_repository.repo.location
}

output "repo_url" {
  value = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "kubeconfig_cmd" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${var.project_id}"
}
