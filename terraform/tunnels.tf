import {
  to = cloudflare_zero_trust_tunnel_cloudflared.home-server-k3s-cf-tunnel
  id = "${var.account_id}/8f73c5f2-4142-405a-91c6-58892f43ed92"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "home-server-k3s-cf-tunnel" {
  account_id = var.account_id
  config_src = "cloudflare"
  name       = "home-server-k3s"
}

