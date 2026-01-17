terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.30"
    }
  }

  backend "s3" {
    region = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
  }
}

locals {
  configuration = yamldecode(file("./configuration.yaml"))
}

resource "hcloud_ssh_key" "main" {
  for_each = {for k, v in local.configuration.vm.keys : k => v if v != null}
  name       = each.key
  public_key = each.value
}

data "hcloud_ssh_key" "main" {
  for_each = {for k, v in local.configuration.vm.keys : k => v if v == null}
  name = each.key
}

resource "hcloud_network" "main" {
    ip_range = "10.0.0.0/16"
    name = "main"
}

resource "hcloud_network_subnet" "main" {
  network_id   = hcloud_network.main.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_server" "main" {
  name        = "main"
  image       = "ubuntu-24.04"
  server_type = local.configuration.vm.server_type
  location = local.configuration.vm.location
  ssh_keys = concat([for k in data.hcloud_ssh_key.main : k.id], [for k in hcloud_ssh_key.main : k.id])
  ignore_remote_firewall_ids = true
  keep_disk = true
  network {
    network_id = hcloud_network.main.id
    ip         = "10.0.0.2"
    alias_ips = [] # https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
  }
  depends_on = [hcloud_network_subnet.main]
  lifecycle {
    ignore_changes = [ssh_keys]
  }
}

output ipv4 {
  value       = hcloud_server.main.ipv4_address
  sensitive   = false
  description = "The IPv4 on the public internet"
}

output ipv6 {
  value       = hcloud_server.main.ipv6_address
  sensitive   = false
  description = "The IPv6 on the public internet"
}
