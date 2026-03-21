locals {
  travisprosser_ca_domain = "travisprosser.ca"
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
resource "cloudflare_zero_trust_tunnel_cloudflared" "home_server_k3s" {
  account_id = var.cf_account_id
  config_src = "cloudflare"
  name       = "home-server-k3s"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "home_server_k3s_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
}

output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.home_server_k3s_token.token
  sensitive = true
}


// DNS CNAME records for each app
resource "cloudflare_dns_record" "apps" {
  for_each = local.apps

  zone_id = var.travisprosser_ca_zone_id
  name    = each.value.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "${each.key} tunnel - managed by Terraform"
}

// Remotely-managed tunnel config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_server_k3s" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
  config = {
    ingress = concat(
      [
        for name, app in local.apps : {
          hostname = "${app.subdomain}.${local.travisprosser_ca_domain}"
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
  for_each = local.apps

  name       = each.key
  account_id = var.cf_account_id
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "${each.value.subdomain}.${local.travisprosser_ca_domain}"
  }]
  policies = each.value.policy_id == null ? null : [{
    id = each.value.policy_id
  }]
}

// Catch-all Application
resource "cloudflare_zero_trust_access_application" "travisprosser_ca_wildcard" {
  account_id                 = var.cf_account_id
  allowed_idps               = []
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  domain                     = "*.travisprosser.ca"
  enable_binding_cookie      = false
  http_only_cookie_attribute = false
  name                       = "Catch-all travisprosser.ca"
  options_preflight_bypass   = false
  session_duration           = "24h"
  tags                       = []
  type                       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "*.travisprosser.ca"
  }]
  policies = [
    {
      id = cloudflare_zero_trust_access_policy.travis_only.id
    }
  ]
}

