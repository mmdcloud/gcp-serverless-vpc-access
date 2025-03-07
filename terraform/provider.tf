terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.24.0"
    }
  }
}

provider "google" {
  project = "nodal-talon-445602-m1"
  region  = "us-central1"
}