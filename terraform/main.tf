terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  backend "s3" {
    bucket                      = "home-server"
    key                         = "home-server-k8s/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    # endpoints = { s3 = "https://${account_id}.r2.cloudflarestorage.com" } / ${AWS_ENDPOINT_URL_S3}
    # access_key = "${AWS_ACCESS_KEY_ID}"
    # secret_key = "${AWS_SECRET_ACCESS_KEY}"
  }
}

provider "cloudflare" {
  # CLOUDFLARE_API_TOKEN=<token>
}

variable "zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "travisprosser.ca"
}

variable "tunnel_id" {
  description = "ID of the Cloudflare Tunnel for the given domain"
  type        = string
  default     = "b073626e-a418-40b0-ade3-3a711b102204"
}


resource "cloudflare_dns_record" "strava" {
  zone_id = var.zone_id
  name    = "strava"
  content = "${var.tunnel_id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "Statistics for Strava tunnel"
}

resource "cloudflare_dns_record" "frigate" {
  zone_id = var.zone_id
  name    = "frigate"
  content = "${var.tunnel_id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  comment = "Frigate tunnel"
}
