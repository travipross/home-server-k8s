// Cloudflare Tunnel Vars
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

// OCI Tailscale Gateway Proxy Vars
variable "oci_tenancy_ocid" {
  description = "Your Tenancy OCID (can also be set via TF_VAR_tenancy_ocid)"
  type        = string
  sensitive   = true
}

variable "oci_instance_ssh_public_key" {
  description = "Public key added to ~/.ssh/authorized_keys on the instance"
  type        = string
}
