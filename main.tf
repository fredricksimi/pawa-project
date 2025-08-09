terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.47.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
  #credentials = "gcp_credentials.json"
}

resource "google_project_service" "artifact_registry_api" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_build_api" {
  project = var.gcp_project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_run_api" {
  project = var.gcp_project_id
  service = "run.googleapis.com"
  disable_on_destroy = false
}



resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = var.gcp_region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = var.docker_image
      ports {
        container_port = 5000
      }
    }
  }
}