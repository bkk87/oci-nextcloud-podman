resource "oci_bastion_bastion" "main" {
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_id
  target_subnet_id = oci_core_subnet.private_subnet.id

  name                         = var.project_name
  client_cidr_block_allow_list = ["0.0.0.0/0"]
}

resource "oci_bastion_session" "session" {
  bastion_id = oci_bastion_bastion.main.id
  key_details {
    public_key_content = file(var.path_ssh_public_key)
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.nextcloud_instance.id

    #Optional
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.nextcloud_instance.private_ip
  }
  session_ttl_in_seconds = 10800
  depends_on             = [time_sleep.wait_seconds]
}

resource "local_file" "oci_sshd_config" {
  count    = var.path_sshd_config_file != null ? 1 : 0
  content  = <<EOT
Host oci
 HostName ${oci_core_instance.nextcloud_instance.private_ip}
 User opc
 Port 22
 IdentityFile ${var.path_ssh_private_key}
 ProxyCommand ssh -i ${var.path_ssh_private_key} -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa -W %h:%p -p 22 ${oci_bastion_session.session.id}@host.bastion.${var.region}.oci.oraclecloud.com
EOT
  filename = var.path_sshd_config_file
}

resource "time_sleep" "wait_seconds" {
  # the bastion can only be established if the instance is running and the bastion plugin is active (this takes some minutes)
  depends_on      = [oci_core_instance.nextcloud_instance]
  create_duration = "400s"
}

