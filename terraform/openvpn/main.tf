terraform {
  required_version = ">=1.11"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

resource "digitalocean_droplet" "openvpn" {
  image    = "debian-12-x64"
  name     = "openvpn"
  region   = "nyc1"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]

  provisioner "local-exec" {
    command = "ANSIBLE_HOME=$(git rev-parse --show-toplevel) ansible-playbook -i '${self.ipv4_address},' main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_REMOTE_USER       = "root"
    }
  }
}

resource "digitalocean_firewall" "openvpn" {
  name = "openvpn"
  droplet_ids = [
    digitalocean_droplet.openvpn.id
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.home_ip]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1194"
    source_addresses = [var.home_ip]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = [var.home_ip]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "853"
    destination_addresses = ["9.9.9.9/32", "149.112.112.112/32"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["9.9.9.9/32", "149.112.112.112/32"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }
}
