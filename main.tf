module "nextcloud" {
  source = "./modules/nextcloud"

  # General
  project_name          = "nextcloud"
  region                = var.region
  compartment_id        = var.compartment_ocid
  tenancy_ocid          = var.tenancy_ocid
  config_file_profile   = var.config_file_profile
  ad_number             = 1
  path_ssh_public_key   = var.path_ssh_public_key
  path_ssh_private_key  = var.path_ssh_private_key
  path_sshd_config_file = var.path_sshd_config_file

  vcn_subnet     = "10.0.0.0/16"
  private_subnet = "10.0.1.0/24"
  public_subnet  = "10.0.2.0/24"

  # object store
  bucket_name = "nextcloud-bucket"
  user_email  = var.user_email
}
