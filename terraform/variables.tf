variable service_account_key_file {
  description = "Path to Key file for Yandex.Cloud API"
}
variable cloud_id {
  description = "Cloud ID"
}
variable folder_id {
  description = "Folder ID"
}
variable region_id {
  description = "region"
  default     = "ru-central1"
}
variable zone {
  description = "Zone"
  default     = "ru-central1-a"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet ID"
}
variable private_key_path {
  description = "path to private key"
}
variable instance_count {
  description = "count instances"
  default     = 1
}
variable app_disk_image {
  description = "Family of disk image for reddit app"
  default     = "reddit-app"
}
variable db_disk_image {
  description = "Family of disk mage for mongodb"
  default     = "reddit-db"
}