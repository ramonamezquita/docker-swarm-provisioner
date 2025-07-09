output "ip_addresses" {
  description = "IP adresses of the VMs"
  value       = join("\n", [for instance in google_compute_instance.vms : instance.network_interface[0].access_config[0].nat_ip])
}
