output "tunnel_token" {
  value       = module.cloudflare_tunnel.tunnel_token
  sensitive   = true
  description = "The secret token to provide to a remotely managed cloudflared instance"
}

output "google_oauth_info" {
  value       = module.cloudflare_tunnel.google_oauth_info
  description = "Details required for setting up OAuth Client in Google Cloud to act as the IdP for Cloudflare Access"
}

output "cloudflare_app_launcher_url" {
  value       = module.cloudflare_tunnel.cloudflare_app_launcher_url
  description = "URL to the Cloudflare App Launcher"
}

output "zone_name" {
  value       = module.cloudflare_tunnel.zone_name
  description = "Cloudflare zone name"
}
