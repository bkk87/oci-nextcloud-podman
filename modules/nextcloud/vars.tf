variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "config_file_profile" {} # see https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#securityTokenAuth
variable "project_name" {}
variable "region" {}
variable "path_ssh_public_key" {}
variable "path_ssh_private_key" {}
variable "vcn_subnet" {}
variable "private_subnet" {}
variable "public_subnet" {}
variable "ad_number" {}
variable "bucket_name" {}
variable "user_email" { nullable = true }
variable "path_sshd_config_file" { nullable = true }
variable "ocid_backup_bootvolume" { nullable = true }
