variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "config_file_profile" {} # see https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#securityTokenAuth
variable "user_email" {
  nullable = true
  default  = null
}

variable "region" {
  default = "eu-frankfurt-1"
}

variable "path_ssh_public_key" {
  type        = string
  description = "full path to a ssh pub key file which is set to access the VM, e.g. /home/user/ssh/id_rsa_oci.pub"
}

variable "path_ssh_private_key" {
  type        = string
  description = "full path to a ssh private key file which is set to access the VM, e.g. /home/user/ssh/id_rsa_oci"
}

variable "path_sshd_config_file" {
  type        = string
  default     = null
  description = "full path to a sshd config file which will be created, e.g. /home/user/.ssh/config.d/oci"
}

variable "ocid_backup_bootvolume" {
  type        = string
  default     = null
  description = "ocid of a backup boot volume to restore from"
}