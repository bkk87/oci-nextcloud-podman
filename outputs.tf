output "loadbalaner_ip" {
  value = module.nextcloud.loadbalacer_ip
}

output "bucket_user_secret_id" {
  value = module.nextcloud.user_secret_id
}

output "bucket_user_secret_key" {
  value = module.nextcloud.user_secret_key
}

output "bastion_session_id" {
  value = module.nextcloud.bastion_session_id
}

output "instance_private_ip" {
  value = module.nextcloud.instance_private_ip
}

output "bucket_hostname" {
  value = module.nextcloud.bucket_hostname
}
