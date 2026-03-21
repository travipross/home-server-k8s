variable "google_oauth_client_id" {
  description = "Client ID for the Google IdP used by Cloudflare Access"
  type        = string
  sensitive   = true
}

variable "google_oauth_client_secret" {
  description = "Client Secret for the Google IdP used by Cloudflare Access"
  type        = string
  sensitive   = true
}


import {
  to = cloudflare_zero_trust_access_identity_provider.otp
  id = "accounts/${var.cf_account_id}/8942b532-862c-45a2-9cb2-0722b821fbc3"
}

resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  name       = "One Time PIN"
  type       = "onetimepin"
  account_id = var.cf_account_id
  config     = {}
}

import {
  to = cloudflare_zero_trust_access_identity_provider.google
  id = "accounts/${var.cf_account_id}/dbb8e2c6-c1e6-447d-83c7-016b1ffb946c"
}

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  name       = "Google"
  type       = "google"
  account_id = var.cf_account_id
  config = {
    client_id     = var.google_oauth_client_id
    client_secret = var.google_oauth_client_secret
    pkce_enabled  = true
  }
}
