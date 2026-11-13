# Regional external HTTP load balancer starter using a zonal unmanaged instance group.
resource "google_compute_instance_group" "web" {
  name      = "${var.name}-ig"
  zone      = var.zone
  instances = ["projects/${var.project_id}/zones/${var.zone}/instances/${var.instance_name}"]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http" {
  name = "${var.name}-hc"

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "web" {
  name                  = "${var.name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http.id]
  backend { group = google_compute_instance_group.web.self_link }
}

resource "google_compute_url_map" "web" {
  name            = "${var.name}-urlmap"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${var.name}-proxy"
  url_map = google_compute_url_map.web.id
}

resource "google_compute_global_forwarding_rule" "web" {
  name                  = "${var.name}-forwarding"
  target                = google_compute_target_http_proxy.web.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}
