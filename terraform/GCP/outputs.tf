output "project_id" {
  value = var.project_id
}

output "vm_name" {
  value = google_compute_instance.web.name
}

output "vm_private_ip" {
  value = google_compute_instance.web.network_interface[0].network_ip
}

output "vm_external_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "load_balancer_ip" {
  value = google_compute_global_address.web.address
}

output "load_balancer_url" {
  value = "http://${google_compute_global_address.web.address}"
}
