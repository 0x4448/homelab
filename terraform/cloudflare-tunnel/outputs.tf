output "nyc_ip" {
  value = digitalocean_droplet.nyc.ipv4_address
}

output "sgp_ip" {
  value = digitalocean_droplet.sgp.ipv4_address
}

output "sgp_client_ip" {
  value = digitalocean_droplet.sgp-client.ipv4_address
}
