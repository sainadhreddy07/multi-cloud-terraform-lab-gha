resource "google_compute_network" "lab" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "web" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.lab.id
  private_ip_google_access = true
}

# GCP has VPC firewall rules rather than an AWS-style Security Group or Azure NSG.
# These Google ranges are used by load-balancer proxies and health checks for this backend model.
resource "google_compute_firewall" "allow_lb_http" {
  name      = var.firewall_name
  network   = google_compute_network.lab.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web-server"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_instance" "web" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["web-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id
    access_config {}
  }

  metadata_startup_script = <<-STARTUP
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    printf '%s\n' '<h1>GCP backend - ${var.vm_name}</h1>' > /var/www/html/index.html
  STARTUP
}

resource "google_compute_instance_group" "web" {
  name      = "${var.load_balancer_name}-instance-group"
  zone      = var.zone
  instances = [google_compute_instance.web.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http" {
  name                = "${var.load_balancer_name}-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "web" {
  name                  = "${var.load_balancer_name}-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.http.id]

  backend {
    group           = google_compute_instance_group.web.self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "web" {
  name            = "${var.load_balancer_name}-url-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${var.load_balancer_name}-http-proxy"
  url_map = google_compute_url_map.web.id
}

resource "google_compute_global_address" "web" {
  name = "${var.load_balancer_name}-global-ip"
}

resource "google_compute_global_forwarding_rule" "web" {
  name                  = "${var.load_balancer_name}-forwarding-rule"
  ip_address            = google_compute_global_address.web.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.web.id
}
