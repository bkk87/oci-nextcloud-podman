# backups: 5 are within the always free tier

resource "oci_core_volume_backup_policy" "daily" {
  compartment_id = var.compartment_id

  display_name = "daily-backups-retention-5-days"
  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = 428400 # 5 days - 1h (terminate oldest backup before creating a new one)
    hour_of_day       = "6"
    offset_type       = "STRUCTURED"
    time_zone         = "UTC"
  }
}

resource "oci_core_volume_group" "daily" {
  availability_domain = data.oci_identity_availability_domain.ad_domain.name
  compartment_id      = var.compartment_id
  source_details {
    type       = "volumeIds"
    volume_ids = [oci_core_instance.nextcloud_instance.boot_volume_id]
  }

  backup_policy_id = oci_core_volume_backup_policy.daily.id

  display_name = "daily-backups"
}