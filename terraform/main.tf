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

variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}
