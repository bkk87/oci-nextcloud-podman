# need a security list for the bastion to egress tcp/22 as it currently does not support NSGs
resource "oci_core_default_security_list" "default" {
  manage_default_resource_id = oci_core_vcn.nextcloud.default_security_list_id
  egress_security_rules {
    destination = var.private_subnet
    protocol    = "6"
    description = "TCP"
  }
}

resource "oci_core_network_security_group" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "public-nsg"
}

resource "oci_core_network_security_group_security_rule" "public_ingress_tcp_80" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.public.id
  protocol                  = "6"

  description = "allow tcp 80 ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "public_ingress_tcp_443" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.public.id
  protocol                  = "6"

  description = "allow tcp 443 ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "public_egress_tcp_udp" {
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.public.id
  protocol                  = "all"

  description = "allow tcp/udp egress"
  destination_type = "CIDR_BLOCK"
  destination      = "0.0.0.0/0"
}


resource "oci_core_network_security_group" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "private-nsg"
}

resource "oci_core_network_security_group_security_rule" "private_self_ingress_tcp" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.private.id
  protocol                  = "6"

  description = "allow ingress tcp from self private nsg"
  source_type = "NETWORK_SECURITY_GROUP"
  source      = oci_core_network_security_group.private.id
}

resource "oci_core_network_security_group_security_rule" "private_ingress_tcp_22" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.private.id
  protocol                  = "6"

  description = "allow tcp 22 ingress"
  source_type = "CIDR_BLOCK"
  source      = var.vcn_subnet

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "private_egress_tcp_udp" {
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.private.id
  protocol                  = "all"

  description = "allow tcp egress"
  destination_type = "CIDR_BLOCK"
  destination      = "0.0.0.0/0"
}
