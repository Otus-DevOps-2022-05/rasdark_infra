variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "path to private key"
}
variable "instance_count" {
  description = "count instances"
  default     = 1
}
variable "app_disk_image" {
  description = "Family of disk image for reddit app"
  default     = "reddit-app"
}
variable "db_disk_image" {
  description = "Family of disk mage for mongodb"
  default     = "reddit-db"
}
variable "stage" {
  description = "Stage"
  default     = "stage"
}
variable "bucket_name" {
  description = "bucket name"
}
variable "enable_provision" {
  description = "Enable provisioner"
  default     = true
}
