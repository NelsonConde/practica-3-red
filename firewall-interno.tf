# La máquina de aplicación puede consultar el servicio de datos.
resource "google_compute_firewall" "datos_http" {
  name      = "${var.prefijo}-permitir-datos-internos"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_tags = ["servidor-web"]
  target_tags = ["servidor-datos"]
}

# Administración de la máquina privada mediante SSH a través de IAP.
resource "google_compute_firewall" "datos_ssh_iap" {
  name      = "${var.prefijo}-permitir-ssh-datos-iap"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["servidor-datos"]
}