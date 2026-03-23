variable "cf_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  sensitive   = true
}

variable "cf_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}

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
