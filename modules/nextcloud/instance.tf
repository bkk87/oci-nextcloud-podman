resource "oci_core_instance" "nextcloud_instance" {
  availability_domain = data.oci_identity_availability_domain.ad_domain.name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  agent_config {

    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
    hostname_label   = "nextcloud-instance"
    nsg_ids          = [oci_core_network_security_group.private.id]
  }

  display_name = "nextcloud-instance"

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  is_pv_encryption_in_transit_enabled = true

  metadata = {
    ssh_authorized_keys = file(var.path_ssh_public_key)
    user_data           = data.cloudinit_config.instance.rendered
  }

  shape_config {
    ocpus         = 4
    memory_in_gbs = 8
  }
  source_details {
    source_id               = var.ocid_backup_bootvolume != null ? var.ocid_backup_bootvolume : data.oci_core_images.ol8.images.0.id
    source_type             = var.ocid_backup_bootvolume != null ? "bootVolume" : "image"
    boot_volume_size_in_gbs = var.ocid_backup_bootvolume != null ? null : 200
  }
  preserve_boot_volume = true

  lifecycle {
    ignore_changes = [metadata, defined_tags, agent_config]
  }
}