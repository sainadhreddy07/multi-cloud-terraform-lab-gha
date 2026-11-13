output "instance_name" { value = google_compute_instance.web.name }
output "internal_ip" { value = google_compute_instance.web.network_interface[0].network_ip }
