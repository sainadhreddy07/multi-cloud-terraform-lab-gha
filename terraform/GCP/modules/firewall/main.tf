resource "google_compute_firewall" "http" {
  name          = "${var.name}-allow-http"
  network       = var.network_name
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.name}-web"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "health_checks" {
  name          = "${var.name}-allow-health-check"
  network       = var.network_name
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["${var.name}-web"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "ssh" {
  count         = length(var.ssh_source_ranges) > 0 ? 1 : 0
  name          = "${var.name}-allow-ssh"
  network       = var.network_name
  direction     = "INGRESS"
  source_ranges = var.ssh_source_ranges
  target_tags   = ["${var.name}-web"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
