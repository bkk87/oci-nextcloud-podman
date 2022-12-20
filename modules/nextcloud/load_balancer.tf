resource "oci_load_balancer" "public_ingress" {
  compartment_id             = var.compartment_id
  display_name               = "public-ingress"
  shape                      = "flexible"
  subnet_ids                 = [oci_core_subnet.public_subnet.id]
  network_security_group_ids = [oci_core_network_security_group.public.id, oci_core_network_security_group.private.id]

  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
}

resource "oci_load_balancer_backend_set" "tcp_80_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "tcp_80_ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 8080
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "tcp_80_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.tcp_80_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "tcp_80"
  port                     = 80
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "tcp_80_backend" {
  backendset_name  = oci_load_balancer_backend_set.tcp_80_ingress.name
  ip_address       = oci_core_instance.nextcloud_instance.private_ip
  load_balancer_id = oci_load_balancer.public_ingress.id
  port             = 80
}

resource "oci_load_balancer_backend_set" "http_8080_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "http_8080_ingress"
  policy           = "ROUND_ROBIN"
  health_checker {
    protocol          = "TCP"
    port              = 8080
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "https_443_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.http_8080_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "https_443"
  port                     = 443
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.rule_set.name]
  ssl_configuration {
    cipher_suite_name       = "oci-modern-ssl-cipher-suite-v1"
    certificate_name        = reverse(sort(data.oci_load_balancer_certificates.certs.certificates[*].certificate_name))[0]
    verify_peer_certificate = false
  }

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "http_8080_backend" {
  backendset_name  = oci_load_balancer_backend_set.http_8080_ingress.name
  ip_address       = oci_core_instance.nextcloud_instance.private_ip
  load_balancer_id = oci_load_balancer.public_ingress.id
  port             = 8080
}

resource "oci_load_balancer_rule_set" "rule_set" {
  items {
    action = "REDIRECT"
    redirect_uri {
      protocol = "https"
      host     = "{host}"
      path     = "/remote.php/dav"
      query    = "?{query}"
    }
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/.well-known/carddav"
      operator        = "PREFIX_MATCH"
    }
    response_code = 301
  }
  items {
    action = "REDIRECT"
    redirect_uri {
      protocol = "https"
      host     = "{host}"
      path     = "/remote.php/dav"
      query    = "?{query}"
    }
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/.well-known/caldav"
      operator        = "PREFIX_MATCH"
    }
    response_code = 301
  }
  items {
    action = "REDIRECT"
    redirect_uri {
      protocol = "https"
      host     = "{host}"
      path     = "/index.php/.well-known/webfinger"
      query    = "?{query}"
    }
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/.well-known/webfinger"
      operator        = "PREFIX_MATCH"
    }
    response_code = 301
  }
  items {
    action = "REDIRECT"
    redirect_uri {
      protocol = "https"
      host     = "{host}"
      path     = "/index.php/.well-known/nodeinfo"
      query    = "?{query}"
    }
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/.well-known/nodeinfo"
      operator        = "PREFIX_MATCH"
    }
    response_code = 301
  }
  items {
    action = "ADD_HTTP_RESPONSE_HEADER"
    header = "Strict-Transport-Security"
    value  = "max-age=15552000; includeSubDomains; preload"
  }
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = replace(oci_load_balancer.public_ingress.display_name, "-", "_")
}