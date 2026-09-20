terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.proyecto
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "${var.prefijo}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "publica" {
  name          = "${var.prefijo}-sub-publica"
  ip_cidr_range = var.cidr_publica
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_instance" "app" {
  name         = "${var.prefijo}-app"
  machine_type = var.tipo_maquina
  zone         = var.zona
  tags         = ["servidor-web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.publica.id
    access_config {}
  }

  metadata_startup_script = file("${path.module}/arranque.sh")
}