import {
  to = cloudflare_zero_trust_access_application.travisprosser_ca_wildcard
  id = "accounts/${var.cf_account_id}/d2dfb8c0-b242-4a3e-963f-f40efe11b7d3"
}

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

