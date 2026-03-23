terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}


// Used for various outputs
data "cloudflare_zero_trust_organization" "cf_org" {
  account_id = var.account_id
}

// Domain name corresponding with provided zone_id
data "cloudflare_zone" "cf_zone" {
  zone_id = var.zone_id
}

locals {
  zone_name = data.cloudflare_zone.cf_zone.name
}
