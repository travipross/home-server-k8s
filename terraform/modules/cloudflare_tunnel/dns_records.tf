// DNS CNAME records for each app
resource "cloudflare_dns_record" "apps" {
  for_each = local.apps

  zone_id = var.zone_id
  name    = each.value.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "${each.key} tunnel - managed by Terraform"
}
