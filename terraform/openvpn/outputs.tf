output "droplet_ip" {
  value = digitalocean_droplet.openvpn.ipv4_address
}
