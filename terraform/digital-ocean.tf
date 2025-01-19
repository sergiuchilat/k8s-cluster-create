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
  description = "The number of worker nodes"
  type        = number
  default     = 8
}

variable "region" {
  description = "The DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "digitalocean_ssh_key_name" {
  description = "The name of the SSH key to use for the droplets"
  type        = string
}

variable "droplet_size_master" {
  description = "The size of the master droplet"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "droplet_size_worker" {
  description = "The size of the worker droplets"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "droplet_size_vpn" {
  description = "The size of the VPN droplet"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "droplet_os_master" {
  description = "The OS for the master droplet"
  type        = string
  default     = "ubuntu-20-04-x64"
}

variable "droplet_os_worker" {
  description = "The OS for the worker droplets"
  type        = string
  default     = "ubuntu-20-04-x64"
}

variable "droplet_os_vpn" {
  description = "The OS for the VPN droplet"
  type        = string
  default     = "ubuntu-20-04-x64"
}

data "digitalocean_ssh_key" "digitalocean_ssh_key" {
  name = var.digitalocean_ssh_key_name
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_droplet" "master" {
  image   = var.droplet_os_master
  name    = "k8s-master"
  region  = var.region
  size    = var.droplet_size_master
  ssh_keys = [data.digitalocean_ssh_key.digitalocean_ssh_key.fingerprint]
}

resource "digitalocean_droplet" "workers" {
  image   = var.droplet_os_worker
  name    = "k8s-worker-${count.index + 1}"
  region  = var.region
  size    = var.droplet_size_worker
  count   = var.workers_count
  ssh_keys = [data.digitalocean_ssh_key.digitalocean_ssh_key.fingerprint]
}

resource "digitalocean_droplet" "vpn" {
  image   = var.droplet_os_vpn
  name    = "k8s-vpn"
  region  = var.region
  size    = var.droplet_size_vpn
  ssh_keys = [data.digitalocean_ssh_key.digitalocean_ssh_key.fingerprint]
}

# Create the Ansible inventory file
resource "local_file" "inventory_file" {
  content  = templatefile("${path.module}/inventory.tpl", {
    master_ip        = digitalocean_droplet.master.ipv4_address
    master_private_ip = digitalocean_droplet.master.ipv4_address_private
    master_id        = digitalocean_droplet.master.id

    worker_ips = [
      for droplet in digitalocean_droplet.workers : {
        name        = droplet.name
        ip          = droplet.ipv4_address
        private_ip  = droplet.ipv4_address_private
        id          = droplet.id
      }
    ]

    vpn_ip         = digitalocean_droplet.vpn.ipv4_address
    vpn_id         = digitalocean_droplet.vpn.id
  })
  filename = "../ansible/inventory.ini"
}

output "master_ip" {
  value = digitalocean_droplet.master.ipv4_address
}

output "worker_ips" {
  value = [
    for droplet in digitalocean_droplet.workers :
    {
      name        = droplet.name
      ip          = droplet.ipv4_address
      private_ip  = droplet.ipv4_address_private
      id          = droplet.id
    }
  ]
}

output "vpn_ip" {
  value = digitalocean_droplet.vpn.ipv4_address
}

output "master_id" {
  value = digitalocean_droplet.master.id
}
