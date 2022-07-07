variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet ID"
}
variable app_disk_image {
  description = "Family of disk image for reddit app"
  default     = "reddit-app"
}
variable stage {
  description = "Stage"
}
variable mongod_ip {
  description = "Mongodb IP"
}
variable private_key_path {
  description = "path to private key"
}
variable enable_provision {
  description = "Enable provisioner"
}
