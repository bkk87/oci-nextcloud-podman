variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "config_file_profile" {} # see https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#securityTokenAuth
variable "user_email" {}

variable "region" {
  default = "eu-frankfurt-1"
}

variable "ssh_public_key" {
  type = string
}