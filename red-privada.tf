# Subred destinada a la máquina de datos.
resource "google_compute_subnetwork" "privada" {
  name          = "${var.prefijo}-sub-privada"
  ip_cidr_range = var.cidr_privada
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Router utilizado por Cloud NAT.
resource "google_compute_router" "privado" {
  name    = "${var.prefijo}-router-privado"
  network = google_compute_network.vpc.id
  region  = var.region
}

# Salida a internet para la subred privada.
resource "google_compute_router_nat" "privado" {
  name                               = "${var.prefijo}-nat-privado"
  router                             = google_compute_router.privado.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.privada.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}