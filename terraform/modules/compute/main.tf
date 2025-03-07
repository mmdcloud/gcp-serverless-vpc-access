# Creating a Virtual Machine
resource "google_compute_instance" "instance" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      network    = network_interface.value["network"]
      subnetwork = network_interface.value["subnetwork"]
    }
  }
  metadata = var.metadata

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  deletion_protection       = var.deletion_protection
  allow_stopping_for_update = var.allow_stopping_for_update
}
