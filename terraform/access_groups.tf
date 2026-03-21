import {
  to = cloudflare_zero_trust_access_group.travis
  id = "accounts/${var.account_id}/e1877b8e-31e3-45d5-bfc1-48201e1903f0"
}

resource "cloudflare_zero_trust_access_group" "travis" {
  account_id = var.account_id
  is_default = true
  name       = "Travis"
  exclude    = []
  include = [{
    email = {
      email = "travisprosser@gmail.com"
    }
    }, {
    email = {
      email = "travis.prosser@lastwall.com"
    }
  }]
  require = []
}


import {
  to = cloudflare_zero_trust_access_group.faris
  id = "accounts/${var.account_id}/6073b42a-2bb2-47d3-8dc8-b6c43f99523f"
}

resource "cloudflare_zero_trust_access_group" "faris" {
  account_id = var.account_id
  name       = "Faris"
  exclude    = []
  include = [{
    email = {
      email = "farismahboob@protonmail.com"
    }
    }, {
    email = {
      email = "fboob17@gmail.com"
    }
    }, {
    email = {
      email = "info@fm17.dev"
    }
  }]
  require = []
}


import {
  to = cloudflare_zero_trust_access_group.emma
  id = "accounts/${var.account_id}/7091e53f-4bda-4c0d-94d1-0dd80aea5689"
}

resource "cloudflare_zero_trust_access_group" "emma" {
  account_id = var.account_id
  name       = "Emma"
  exclude    = []
  include = [{
    email = {
      email = "etompkins.pr@gmail.com"
    }
    }, {
    email = {
      email = "emma@housecatarts.com"
    }
  }]
  require = []
}


import {
  to = cloudflare_zero_trust_access_group.travis_and_emma
  id = "accounts/${var.account_id}/a20a9647-ae1c-48d0-b29b-d7f68c070d91"
}

resource "cloudflare_zero_trust_access_group" "travis_and_emma" {
  account_id = var.account_id
  name       = "Travis and Emma"
  exclude    = []
  include = [{
    group = {
      id = "7091e53f-4bda-4c0d-94d1-0dd80aea5689"
    }
    }, {
    group = {
      id = "e1877b8e-31e3-45d5-bfc1-48201e1903f0"
    }
  }]
  require = []
}

