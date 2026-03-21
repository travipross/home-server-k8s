variable "domain" {
  description = "Domain name"
  type        = string
  default     = "travisprosser.ca"
}

variable "tunnel_id" {
  description = "ID of the Cloudflare Tunnel for the given domain"
  type        = string
  default     = "b073626e-a418-40b0-ade3-3a711b102204"
}

variable "zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  sensitive   = true
}

locals {
  raw_apps = {
    "Strava" = {
      subdomain = "strava"
      service   = "http://strava-statistics.misc:8080"
      policy_id = cloudflare_zero_trust_access_policy.travis_and_emma.id
    },
    "Frigate" = {
      subdomain = "frigate"
      service   = "http://frigate.iot:5000"
      policy_id = cloudflare_zero_trust_access_policy.travis_and_emma.id
    },
    "Hello World" = {
      subdomain = "helloworld"
      service   = "hello_world"
    }
  }

  default_policy_id = cloudflare_zero_trust_access_policy.travis_only.id

  // overlay map to apply default values
  apps = {
    for name, config in local.raw_apps : name => {
      subdomain = config.subdomain
      service   = config.service
      // replace null or missing with default
      policy_id = coalesce(try(config.policy_id, null), local.default_policy_id)
    }
  }
}

// Tunnel
import {
  to = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s
  id = "${var.account_id}/8f73c5f2-4142-405a-91c6-58892f43ed92"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "home_server_k3s" {
  account_id = var.account_id
  config_src = "cloudflare"
  name       = "home-server-k3s"
}


// DNS CNAME records for each app
resource "cloudflare_dns_record" "apps" {
  for_each = local.apps
  zone_id  = var.zone_id
  name     = each.value.subdomain
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
  comment  = "${each.key} tunnel - managed by Terraform"
}

// Remotely-managed tunnel config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_server_k3s" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
  config = {
    ingress = concat(
      [
        for name, app in local.apps : {
          hostname = "${app.subdomain}.${var.domain}"
          service  = app.service
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}

// Cloudflare Access Applications
resource "cloudflare_zero_trust_access_application" "apps" {
  for_each   = local.apps
  name       = each.key
  account_id = var.account_id
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "${each.value.subdomain}.${var.domain}"
  }]

  policies = each.value.policy_id == null ? null : [{
    id = each.value.policy_id
  }]
}
