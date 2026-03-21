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

resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  name       = "One Time PIN"
  type       = "onetimepin"
  account_id = var.cf_account_id
  config     = {}
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

data "cloudflare_zero_trust_organization" "cf_org" {
  account_id = var.cf_account_id
}

output "google_oauth_info" {
  value = <<-EOT
  In Google Cloud Console (Google Auth Platform > Clients), set:

  Authorized JavaScript origins:
    - https://${data.cloudflare_zero_trust_organization.cf_org.auth_domain}
  Authorized Redirect URIs:
    - https://${data.cloudflare_zero_trust_organization.cf_org.auth_domain}/cdn-cgi/access/callback

  Console Link: https://console.cloud.google.com/auth/clients
  EOT

}

output "cloudflare_app_launcher_url" {
  value = "https://${data.cloudflare_zero_trust_organization.cf_org.auth_domain}"
}
