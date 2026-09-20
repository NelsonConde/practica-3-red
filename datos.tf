# Máquina de datos ubicada en la segunda subred.
resource "google_compute_instance" "datos" {
  name         = "${var.prefijo}-datos"
  machine_type = var.tipo_maquina
  zone         = var.zona
  tags         = ["servidor-datos"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.privada.id
  }

  metadata_startup_script = file("${path.module}/arranque-datos.sh")

  depends_on = [google_compute_router_nat.privado]
}