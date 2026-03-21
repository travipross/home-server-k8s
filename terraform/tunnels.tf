import {
  to = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s
  id = "${var.account_id}/8f73c5f2-4142-405a-91c6-58892f43ed92"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "home_server_k3s" {
  account_id = var.account_id
  config_src = "cloudflare"
  name       = "home-server-k3s"
}


resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_server_k3s" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
  config = {
    ingress = [
      {
        hostname = "helloworld.${var.domain}"
        service  = "hello_world"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "helloworld" {
  zone_id = var.zone_id
  name    = "helloworld"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "Test tunnel"
}


resource "cloudflare_zero_trust_access_application" "helloworld" {
  account_id = var.account_id
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "${cloudflare_dns_record.helloworld.name}.${var.domain}"
  }]
  policies = [{
    id         = cloudflare_zero_trust_access_policy.travis_and_emma.id
    precedence = 1000
  }]
}
