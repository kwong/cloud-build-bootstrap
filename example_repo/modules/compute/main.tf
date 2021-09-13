resource "google_compute_instance" "example_instance" {
  project      = var.project
  zone         = "asia-southeast1-a"
  name         = "gce-instance-${var.environment}"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = var.subnet
  }

  metadata = {
    env = var.environment
  }

}
