
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet ID"
}
variable db_disk_image {
  description = "Family of disk mage for mongodb"
  default     = "reddit-db"
}
variable folder_id {
  description = "Folder ID"
}
variable stage {
  description = "Stage"
}
variable private_key_path {
  description = "path to private key"
}
