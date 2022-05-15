# Object storage

resource "oci_objectstorage_bucket" "test_bucket" {
    compartment_id = var.compartment_id
    name = var.bucket_name
    namespace = data.oci_objectstorage_namespace.this.namespace

    #Optional
    access_type = "NoPublicAccess"
    auto_tiering = "Disabled"

    object_events_enabled = false
    storage_tier = "Standard"
    versioning = "Disabled"
}

# Object storage IAM

resource "oci_identity_user" "nextcloud" {
    compartment_id = var.compartment_id
    description = "nextcloud user to access the object storage"
    name = "nextcloud"
}

resource "oci_identity_group" "nextcloud" {
    compartment_id = var.compartment_id
    description = "nextcloud user group to access the object storage"
    name = "nextcloud"
}

resource "oci_identity_user_group_membership" "group_membership" {
    group_id = oci_identity_group.nextcloud.id
    user_id = oci_identity_user.nextcloud.id
}

resource "oci_identity_customer_secret_key" "this" {
    display_name = "nextcloud user secret key"
    user_id = oci_identity_user.nextcloud.id
}

resource "oci_identity_policy" "access_object_store_policy" {
    compartment_id = var.compartment_id
    description = "allow nextcloud group to access the bucket"
    name = "access_object_storage"
    statements = [
        "Allow group ${oci_identity_group.nextcloud.name} to read buckets in tenancy",
        "Allow group ${oci_identity_group.nextcloud.name} to manage objects in tenancy"
    ]
}

resource "oci_identity_user_capabilities_management" "nextcloud" {
    user_id = oci_identity_user.nextcloud.id

    can_use_api_keys             = "false"
    can_use_auth_tokens          = "true"
    can_use_console_password     = "false"
    can_use_customer_secret_keys = "true"
    can_use_smtp_credentials     = "false"
}