terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  # version                  = 0.35
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  app_disk_image   = var.app_disk_image
  subnet_id        = module.vpc.subnet_id
  folder_id        = var.folder_id
  stage            = var.stage
  mongod_ip        = module.db.internal_ip_address
  private_key_path = var.private_key_path
  depends_on       = [module.db.internal_ip_address]
}

module "db" {
  source           = "../modules/db"
  public_key_path  = var.public_key_path
  db_disk_image    = var.db_disk_image
  subnet_id        = module.vpc.subnet_id
  folder_id        = var.folder_id
  stage            = var.stage
  private_key_path = var.private_key_path
  depends_on       = [module.vpc.subnet_id]
}

module "vpc" {
  source   = "../modules/vpc"
  stage    = var.stage
  ip_range = var.ip_range
}
