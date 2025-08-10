terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.47.0"
    }
  }
}

# Providing our Service Account Credientials and authenticating with GCP
provider "google" {
  project = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
  #credentials = "gcp_credentials.json"
}

# Enabling the Artifact Registry API on GCP
resource "google_project_service" "artifact_registry_api" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Enabling the Cloud Build API on GCP
resource "google_project_service" "cloud_build_api" {
  project = var.gcp_project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# Enabling the Cloud Run API on GCP
resource "google_project_service" "cloud_run_api" {
  project = var.gcp_project_id
  service = "run.googleapis.com"
  disable_on_destroy = false
}

# Creating an Artifact Registry Repository
resource "google_artifact_registry_repository" "my_repo" {
  location      = var.gcp_region
  repository_id = var.repo_name
  description   = "My docker repository"
  format        = "DOCKER"
  depends_on = [google_project_service.artifact_registry_api]
  lifecycle {
    ignore_changes = [ description ]
  }
}

# Creating our Serveless VPC Access Connector on GCP that 
# will connect our Cloud Run Service to our VPC in use. We'll deploy a VM in this VPC to test the Cloud Run Service
resource "google_vpc_access_connector" "connector" {
  name          = "my-serverless-connector"
  subnet {
    name = google_compute_subnetwork.custom_subnetwork.name
  }
  machine_type = var.gcp_serverless_machine_type
  min_instances = var.gcp_serverless_min_instances
  max_instances = var.gcp_serverless_max_instances
  region        = var.gcp_region
}

# This is the subnetwork that will be used by the Serveless VPC Access Connector
resource "google_compute_subnetwork" "custom_subnetwork" {
  name          = "vpc-access-subnetwork"
  ip_cidr_range = var.gcp_serverless_vpc_subnet
  region        = var.gcp_region
  network       = var.gcp_vpc_network
  lifecycle {
    ignore_changes = [ name ]
  }
}



###------------ THIS BLOCK BELOW WILL BE EXECUTED BY OUR CLOUD BUILD PROCESS WHEN REPO IS PUSHED TO GITHUB ---------------#####
###--------------------------------- COMMENT OUT LINE 15 (GCP CREDENTIALS FILE)-------------------------------------------#####

# Creating our Cloud Run Service on GCP. 
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = var.gcp_region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY" # Setting the cloud Run service to Internal Traffic only

  template {
    containers {
      image = var.docker_image
      ports {
        container_port = 5000
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress = "ALL_TRAFFIC"
    }
  }
}