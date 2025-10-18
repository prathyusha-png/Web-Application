variable "project_id" {
  description = "GCP project id"
  type        = string
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}
variable "cluster_name" {
  default = "hello-gke-cluster"
}
variable "node_machine_type" {
  default = "e2-medium"
}
variable "node_count" {
  default = 2
}
variable "artifact_repo_location" {
  default = "us-central1"
}
