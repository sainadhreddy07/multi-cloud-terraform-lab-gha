resource "google_compute_instance" "web" {
  name         = "${var.name}-web"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["${var.name}-web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    access_config {}
  }

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>GCP backend - ${var.name}</h1>" > /var/www/html/index.html
  SCRIPT
}
