resource "oci_core_vcn" "nextcloud" {
  dns_label      = "nextcloud"
  cidr_block     = var.vcn_subnet
  compartment_id = var.compartment_id
  display_name   = "nextcloud"
}

resource "oci_core_internet_gateway" "nextcloud_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "nextcloud_vcn_igw"
}

resource "oci_core_nat_gateway" "nextcloud_ngw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "nextcloud_vcn_ngw"
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block     = var.public_subnet
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "nextcloud_public_subnet"
  dns_label      = "public"
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.nextcloud.id
  display_name               = "nextcloud_private_subnet"
  route_table_id             = oci_core_route_table.private_subnet.id
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_default_route_table" "nextcloud" {
  manage_default_resource_id = oci_core_vcn.nextcloud.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.nextcloud_igw.id

    description = "public subnet egress to internet gateway"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_route_table" "private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id

  display_name = "private_subnet_egress_natgw"

  route_rules {
    network_entity_id = oci_core_nat_gateway.nextcloud_ngw.id

    description = "private subnet egress to natgw"
    destination = "0.0.0.0/0"
  }
}