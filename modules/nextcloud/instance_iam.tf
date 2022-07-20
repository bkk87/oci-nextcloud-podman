
resource "oci_identity_dynamic_group" "manage_lb" {
  compartment_id = var.compartment_id
  description    = "allow instance to manage the lb"
  matching_rule  = "any {instance.id = '${oci_core_instance.nextcloud_instance.id}'}"
  name           = "allow_lb_access"
}

resource "oci_identity_policy" "cert_renewal_policy" {
  compartment_id = var.tenancy_ocid
  description    = "instances manage the load balancers for cert renewal"
  name           = "instances_access_lb"
  statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.manage_lb.name} to manage load-balancers in tenancy"]
}
