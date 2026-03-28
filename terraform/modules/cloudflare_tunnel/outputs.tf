output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.home_server_k3s_token.token
  sensitive   = true
  description = "The secret token to provide to a remotely managed cloudflared instance"
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

  description = "Details required for setting up OAuth Client in Google Cloud to act as the IdP for Cloudflare Access"
}

output "cloudflare_app_launcher_url" {
  value       = "https://${data.cloudflare_zero_trust_organization.cf_org.auth_domain}"
  description = "URL to the Cloudflare App Launcher"
}

output "zone_name" {
  value       = local.zone_name
  description = "Cloudflare zone name"
}
