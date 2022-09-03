output "ad" {
  value = data.oci_identity_availability_domain.ad_domain
}

output "loadbalacer_ip" {
  value = oci_load_balancer.public_ingress.ip_address_details[0].ip_address
}

output "user_secret_id" {
  value = oci_identity_customer_secret_key.this.id
}

output "user_secret_key" {
  value = oci_identity_customer_secret_key.this.key
}

output "bastion_session_id" {
  value = oci_bastion_session.session.id
}

output "instance_private_ip" {
  value = oci_core_instance.nextcloud_instance.private_ip
}

output "bucket_hostname" {
  value = "${data.oci_objectstorage_namespace.this.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}