import {
  to = cloudflare_zero_trust_access_policy.faris_with_justification
  id = "${var.cf_account_id}/80666b3b-b639-4530-921b-f87d3caf7603"
}

resource "cloudflare_zero_trust_access_policy" "faris_with_justification" {
  account_id                     = var.cf_account_id
  approval_required              = true
  decision                       = "allow"
  name                           = "Faris with Justification"
  purpose_justification_prompt   = "Why u access?"
  purpose_justification_required = true
  session_duration               = "24h"
  approval_groups = [{
    approvals_needed = 1
    email_addresses  = ["travisprosser@gmail.com"]
  }]
  exclude = []
  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.faris.id
    }
  }]
  require = []
}


import {
  to = cloudflare_zero_trust_access_policy.travis_only
  id = "${var.cf_account_id}/3db950c7-d962-4c48-9bb0-896cdad01ef2"
}

resource "cloudflare_zero_trust_access_policy" "travis_only" {
  account_id       = var.cf_account_id
  decision         = "allow"
  name             = "Travis Only"
  session_duration = "24h"
  exclude          = []
  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.travis.id
    }
  }]
  require = []
}


import {
  to = cloudflare_zero_trust_access_policy.travis_and_emma
  id = "${var.cf_account_id}/0d42bd9f-2538-45d4-8cc5-f18b1a48e8dc"
}

resource "cloudflare_zero_trust_access_policy" "travis_and_emma" {
  account_id       = var.cf_account_id
  decision         = "allow"
  name             = "Travis and Emma"
  session_duration = "24h"
  exclude          = []
  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.travis_and_emma.id
    }
  }]
  require = []
}

