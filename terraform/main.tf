terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.18.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "8.5.0"
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

provider "oci" {
  # OCI_FINGERPRINT=<...>
  # OCI_PRIVATE_KEY_PATH=<...>
  # OCI_REGION=<...>
  # OCI_TENANCY_OCID=<...>
  # OCI_USER_OCID=<...>
}

module "cloudflare_tunnel" {
  source                     = "./modules/cloudflare_tunnel"
  google_oauth_client_id     = var.google_oauth_client_id
  google_oauth_client_secret = var.google_oauth_client_secret
  account_id                 = var.cf_account_id
  zone_id                    = var.cf_zone_id
}

module "oci_gateway_proxy" {
  source                  = "./modules/oci_gateway_proxy"
  compartment_id          = var.oci_tenancy_ocid
  instance_ssh_public_key = var.oci_instance_ssh_public_key
}


import {
  to = module.oci_gateway_proxy.oci_core_instance.gateway_node
  id = "ocid1.instance.oc1.ca-montreal-1.an4xkljr5mpa37qcm24tmy6wem6jj6tehojmw6wj4li7jrwvnceah2lqrrtq"
}
