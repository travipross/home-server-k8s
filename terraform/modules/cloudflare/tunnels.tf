locals {
  raw_apps = {
    "Strava" = {
      subdomain = "strava"
      policy_id = cloudflare_zero_trust_access_policy.travis_and_emma.id
    },
    "Frigate" = {
      subdomain = "frigate"
      policy_id = cloudflare_zero_trust_access_policy.travis_and_emma.id
    },
    "Hello World" = {
      subdomain = "helloworld"
      service   = "hello_world"
    }
  }

  default_policy_id = cloudflare_zero_trust_access_policy.travis_only.id
  default_service   = "https://traefik.traefik.svc.cluster.local:443" # Gateway LoadBalancer service

  // overlay map to apply default values
  apps = {
    for name, config in local.raw_apps : name => {
      subdomain = config.subdomain
      // replace null or missing vals with defaults
      service   = coalesce(try(config.service, null), local.default_service)
      policy_id = coalesce(try(config.policy_id, null), local.default_policy_id)
    }
  }
}

// Tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "home_server_k3s" {
  account_id = var.account_id
  config_src = "cloudflare"
  name       = "home-server-k3s"
}

// Token for tunnel, to be used with cloudflared agent
data "cloudflare_zero_trust_tunnel_cloudflared_token" "home_server_k3s_token" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
}


// Remotely-managed tunnel config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_server_k3s" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_server_k3s.id
  config = {
    origin_request = {
      match_sn_ito_host = true # Ensures cloudflared sets the appropriate value for SNI so that Traefik can present a valid TLS cert
    }
    ingress = concat(
      [
        for name, app in local.apps : {
          hostname = "${app.subdomain}.${local.zone_name}"
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


