# backups: 5 are within the always free tier:
# 4 weekly and 
# 1 manual backup (not part of this terraform code)

resource "oci_core_volume_backup_policy" "weekly" {
  compartment_id = var.compartment_id

  display_name = "weekly-retention-4-weeks"
  schedules {
    backup_type       = "FULL"
    period            = "ONE_WEEK"
    retention_seconds = 2419200 # 4 weeks
  }
}


resource "oci_core_volume_group" "weekly" {
    availability_domain = data.oci_identity_availability_domain.ad_domain.name
    compartment_id = var.compartment_id
    source_details {
        type = "volumeIds"
        volume_ids = [oci_core_instance.nextcloud_instance.boot_volume_id]
    }

    backup_policy_id = oci_core_volume_backup_policy.weekly.id

    display_name = "weekly-backups"
}

