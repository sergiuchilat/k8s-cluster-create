terraform {
  required_version = "~> 1.5.7"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "digitalocean_token" {
  description = "The token for the DigitalOcean API"
  type        = string
  sensitive   = true
}

variable "workers_count" {
  type = number
}

variable "region" {
  type = string
}

variable digitalocean_ssh_key_name {
  type = string
}

variable "droplet_size_master" {
  type = string
}

variable "droplet_size_worker" {
  type = string
}

variable "droplet_os_master" {
  type = string
}

variable "droplet_os_worker" {
  type = string
}

data "digitalocean_ssh_key" digitalocean_ssh_key {
  name = var.digitalocean_ssh_key_name
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_droplet" "master" {
  image  = var.droplet_os_master
  name   = "master"
  region = var.region
  size   = var.droplet_size_master
  ssh_keys = [data.digitalocean_ssh_key.digitalocean_ssh_key.fingerprint]
}

resource "digitalocean_droplet" "workers" {
  image  = var.droplet_os_worker
  name   = "node-${count.index + 1}"
  region = var.region
  size   = var.droplet_size_worker
  count  = var.workers_count
  ssh_keys = [data.digitalocean_ssh_key.digitalocean_ssh_key.fingerprint]
}

output "master_ip" {
  value = "master ansible_host=${digitalocean_droplet.master.ipv4_address} ansible_public_ip=${digitalocean_droplet.master.ipv4_address} ansible_private_ip=${digitalocean_droplet.master.ipv4_address_private}"
}

output "worker_ips" {
  value = join("\n", [
    for droplet in digitalocean_droplet.workers :
    "${droplet.name} ansible_host=${droplet.ipv4_address} ansible_public_ip=${droplet.ipv4_address} ansible_private_ip=${droplet.ipv4_address_private}"
  ])
}
