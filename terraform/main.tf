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

variable "account_id" {
  description = "Cloudflare Account ID"
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

locals {
  locally_managed_tunnel_address = "${var.tunnel_id}.cfargotunnel.com"
}


