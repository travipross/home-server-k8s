// Cloudflare Access Applications
resource "cloudflare_zero_trust_access_application" "apps" {
  for_each = local.apps

  name       = each.key
  account_id = var.account_id
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "${each.value.subdomain}.${local.zone_name}"
  }]
  policies = each.value.policy_id == null ? null : [{
    id = each.value.policy_id
  }]
}

// Catch-all Application
resource "cloudflare_zero_trust_access_application" "zone_wildcard" {
  account_id                 = var.account_id
  allowed_idps               = []
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  domain                     = "*.${local.zone_name}"
  enable_binding_cookie      = false
  http_only_cookie_attribute = false
  name                       = "Catch-all ${local.zone_name}"
  options_preflight_bypass   = false
  session_duration           = "24h"
  tags                       = []
  type                       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "*.${local.zone_name}"
  }]
  policies = [
    {
      id = cloudflare_zero_trust_access_policy.travis_only.id
    }
  ]
}
