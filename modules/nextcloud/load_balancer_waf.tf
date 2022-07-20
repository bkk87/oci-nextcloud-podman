resource "oci_waf_web_app_firewall" "nextcloud" {
  backend_type               = "LOAD_BALANCER"
  compartment_id             = var.compartment_id
  load_balancer_id           = oci_load_balancer.public_ingress.id
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.nextcloud.id
  display_name               = "nextcloud-waf"
}

resource "oci_waf_web_app_firewall_policy" "nextcloud" {
  compartment_id = var.compartment_id
  actions {
    name = "Pre-configured Check Action"
    type = "CHECK"
  }
  actions {
    name = "Pre-configured Allow Action"
    type = "ALLOW"
  }
  actions {
    name = "Pre-configured 401 Response Code Action"
    type = "RETURN_HTTP_RESPONSE"
    body {
      text = "{\"code\":\"401\",\"message\":\"Unauthorized\"}"
      type = "STATIC_TEXT"
    }
    code = 401
    headers {
      name  = "Content-Type"
      value = "application/json"
    }
  }
  display_name = "nextcloud-waf-policy"
  request_protection {
    body_inspection_size_limit_in_bytes = 8192
    rules {
      action_name = "Pre-configured 401 Response Code Action"
      name        = "body-inspection"
      protection_capabilities {
        key     = 9420000
        version = 2
      }
      protection_capabilities {
        key     = 941140
        version = 2
      }
      protection_capabilities {
        key     = 9410000
        version = 3
      }
      protection_capabilities {
        key     = 9330000
        version = 2
      }
      protection_capabilities {
        key     = 9320001
        version = 2
      }
      protection_capabilities {
        key     = 9320000
        version = 2
      }
      protection_capabilities {
        key     = 930120
        version = 2
      }
      protection_capabilities {
        key     = 9300000
        version = 2
      }
      protection_capabilities {
        key     = 920390
        version = 1
      }
      protection_capabilities {
        key     = 920380
        version = 1
      }
      protection_capabilities {
        key     = 920370
        version = 1
      }

      protection_capabilities {
        key                            = 933210
        version                        = 1
        collaborative_action_threshold = 1
      }
      protection_capabilities {
        key     = 933200
        version = 1

      }
      protection_capabilities {
        key     = 933190
        version = 1

      }
      protection_capabilities {
        key     = 933180
        version = 2

      }
      protection_capabilities {
        key     = 933170
        version = 2

      }
      protection_capabilities {
        key     = 933161
        version = 2

      }
      protection_capabilities {
        key     = 933151
        version = 2

      }
      protection_capabilities {
        key     = 933140
        version = 2

      }
      protection_capabilities {
        key     = 933131
        version = 2

      }
      protection_capabilities {
        key     = 933130
        version = 2

      }
      protection_capabilities {
        key     = 933120
        version = 2

      }
      protection_capabilities {
        key     = 933111
        version = 2

      }
      protection_capabilities {
        key     = 933110
        version = 2

      }
      protection_capabilities {
        key     = 933100
        version = 2
      }
      protection_capabilities {
        key     = 933150
        version = 2
      }
      protection_capabilities {
        key     = 933160
        version = 2
      }
      type = "PROTECTION"

      condition_language         = "JMESPATH"
      is_body_inspection_enabled = true
    }
  }
}