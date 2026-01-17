provider "cloudflare" {}

data "cloudflare_zone" "zones" {
  for_each = local.configuration.cloudflare.zones
  name     = each.key
}

resource "cloudflare_record" "domain_a" {
  for_each = local.configuration.cloudflare.zones

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "*"
  type    = "A"
  content = hcloud_server.main.ipv4_address
  proxied = true
}

resource "cloudflare_record" "domain_aaaa" {
  for_each = local.configuration.cloudflare.zones

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "*"
  type    = "AAAA"
  content = hcloud_server.main.ipv6_address
  proxied = true
}
