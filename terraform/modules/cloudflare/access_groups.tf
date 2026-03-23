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

resource "cloudflare_zero_trust_access_group" "travis_and_emma" {
  account_id = var.account_id
  name       = "Travis and Emma"
  exclude    = []
  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.emma.id
    }
    }, {
    group = {
      id = cloudflare_zero_trust_access_group.travis.id
    }
  }]
  require = []
}
