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

resource "digitalocean_vpc" "vpc-nyc" {
  name     = "vnc-nyc"
  region   = "nyc1"
  ip_range = "192.168.50.0/24"
}

resource "digitalocean_vpc" "vpc-sgp" {
  name     = "vnc-sgp"
  region   = "sgp1"
  ip_range = "192.168.51.0/24"
}

resource "digitalocean_droplet" "nyc" {
  image    = "debian-12-x64"
  name     = "nyc"
  region   = "nyc1"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  vpc_uuid = digitalocean_vpc.vpc-nyc.id

  provisioner "local-exec" {
    command = "ANSIBLE_HOME=$(git rev-parse --show-toplevel) ansible-playbook -i '${self.ipv4_address},' main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_REMOTE_USER       = "root"
    }
  }
}

resource "digitalocean_droplet" "sgp" {
  image    = "debian-12-x64"
  name     = "sgp"
  region   = "sgp1"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  vpc_uuid = digitalocean_vpc.vpc-sgp.id

  provisioner "local-exec" {
    command = "ANSIBLE_HOME=$(git rev-parse --show-toplevel) ansible-playbook -i '${self.ipv4_address},' main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_REMOTE_USER       = "root"
    }
  }
}

resource "digitalocean_droplet" "sgp-client" {
  image    = "debian-12-x64"
  name     = "sgp-client"
  region   = "sgp1"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  vpc_uuid = digitalocean_vpc.vpc-sgp.id
}

resource "digitalocean_firewall" "firewall" {
  name = "firewall"
  droplet_ids = [
    digitalocean_droplet.nyc.id,
    digitalocean_droplet.sgp.id
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.home_ip]
  }

  inbound_rule {
    protocol = "icmp"
    source_addresses = [
      var.home_ip,
      "192.168.0.0/16",
      "100.96.0.0/12"
    ]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "853"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
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

  # Cloudflared Tunnel
  # https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/tunnel-with-firewall/
  outbound_rule {
    protocol   = "tcp"
    port_range = "7844"
    destination_addresses = [
      "198.41.192.167/32",
      "198.41.192.67/32",
      "198.41.192.57/32",
      "198.41.192.107/32",
      "198.41.192.27/32",
      "198.41.192.7/32",
      "198.41.192.227/32",
      "198.41.192.47/32",
      "198.41.192.37/32",
      "198.41.192.77/32",
      "198.41.200.13/32",
      "198.41.200.193/32",
      "198.41.200.33/32",
      "198.41.200.233/32",
      "198.41.200.53/32",
      "198.41.200.63/32",
      "198.41.200.113/32",
      "198.41.200.73/32",
      "198.41.200.43/32",
      "198.41.200.23/32",
    ]
  }

  # Cloudflared Tunnel
  # https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/tunnel-with-firewall/
  outbound_rule {
    protocol   = "udp"
    port_range = "7844"
    destination_addresses = [
      "198.41.192.167/32",
      "198.41.192.67/32",
      "198.41.192.57/32",
      "198.41.192.107/32",
      "198.41.192.27/32",
      "198.41.192.7/32",
      "198.41.192.227/32",
      "198.41.192.47/32",
      "198.41.192.37/32",
      "198.41.192.77/32",
      "198.41.200.13/32",
      "198.41.200.193/32",
      "198.41.200.33/32",
      "198.41.200.233/32",
      "198.41.200.53/32",
      "198.41.200.63/32",
      "198.41.200.113/32",
      "198.41.200.73/32",
      "198.41.200.43/32",
      "198.41.200.23/32",
    ]
  }

  # WARP Connector Tunnel
  # https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/firewall/
  outbound_rule {
    protocol   = "udp"
    port_range = "2408"
    destination_addresses = [
      "162.159.192.0/24",
      "162.159.193.0/24",
    ]
  }
}
