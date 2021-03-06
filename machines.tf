resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
      // Ephemeral IP
    }
  }
  
  lifecycle {
    ignore_changes = [attached_disk]
  }

}

resource "google_compute_network" "vpc_network" {
  name = "batatinhas-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_instance" "web" {
  name         = "web"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
      // Ephemeral IP
    }
  }

  depends_on = [
    google_compute_instance.default,
  ]
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = google_compute_instance.default.id

  depends_on = [
    google_compute_instance.default, google_compute_disk.default,
  ]

}


resource "google_compute_disk" "default" {
  name  = "test-disk"
  type  = "pd-standard"
  zone  = "us-central1-a"
  physical_block_size_bytes = 4096
}