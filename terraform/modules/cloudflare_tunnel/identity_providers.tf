resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  name       = "One Time PIN"
  type       = "onetimepin"
  account_id = var.account_id
  config     = {}
}

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  name       = "Google"
  type       = "google"
  account_id = var.account_id
  config = {
    client_id     = var.google_oauth_client_id
    client_secret = var.google_oauth_client_secret
    pkce_enabled  = true
  }
}


