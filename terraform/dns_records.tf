resource "cloudflare_dns_record" "strava" {
  zone_id = var.zone_id
  name    = "strava"
  content = local.locally_managed_tunnel_address
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "Statistics for Strava tunnel"
}

resource "cloudflare_dns_record" "frigate" {
  zone_id = var.zone_id
  name    = "frigate"
  content = local.locally_managed_tunnel_address
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "Frigate tunnel"
}

