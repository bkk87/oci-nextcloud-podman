module "nextcloud" {
  source = "./modules/nextcloud"

  # General
  project_name        = "nextcloud"
  region              = var.region
  compartment_id      = var.compartment_ocid
  tenancy_ocid        = var.tenancy_ocid
  config_file_profile = var.config_file_profile
  ad_number           = 1
  ssh_public_key      = var.ssh_public_key #file("~/.ssh/id_rsa_oci.pub")

  vcn_subnet     = "10.0.0.0/16"
  private_subnet = "10.0.1.0/24"
  public_subnet  = "10.0.2.0/24"

  # object store
  bucket_name = "nextcloud-bucket"
}
