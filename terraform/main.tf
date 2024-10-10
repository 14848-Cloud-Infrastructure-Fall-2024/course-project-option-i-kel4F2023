variable "project_id" {
  description = "The GCP Project ID"
}

provider "google" {
  project = var.project_id
  region  = "us-west1-a"
}

# The rest of your Terraform configuration remains the same
# Create a GKE cluster for Jenkins and SonarQube
resource "google_container_cluster" "jenkins_sonarqube_cluster" {
  name     = "jenkins-sonarqube-cluster"
  location = "us-west1-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "jenkins_sonarqube_nodes" {
  name       = "jenkins-sonarqube-node-pool"
  location   = "us-west1-a"
  cluster    = google_container_cluster.jenkins_sonarqube_cluster.name
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
  }
}

# Create a GKE cluster for Hadoop
resource "google_container_cluster" "hadoop_cluster" {
  name     = "hadoop-cluster"
  location = "us-west1-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "hadoop_nodes" {
  name       = "hadoop-node-pool"
  location   = "us-west1-a"
  cluster    = google_container_cluster.hadoop_cluster.name
  node_count = 3  # 1 master, 2 workers

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
  }
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "gke-network"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  region        = "us-west1"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# Output the cluster names and project ID
output "project_id" {
  value = var.project_id
}

output "jenkins_sonarqube_cluster_name" {
  value = google_container_cluster.jenkins_sonarqube_cluster.name
}

output "hadoop_cluster_name" {
  value = google_container_cluster.hadoop_cluster.name
}