terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  app_disk_image   = var.app_disk_image
  subnet_id        = module.vpc.subnet_id
  stage            = var.stage
  mongod_ip        = module.db.internal_ip_address
  private_key_path = var.private_key_path
  enable_provision = var.enable_provision
  depends_on       = [module.db.internal_ip_address]
}

module "db" {
  source           = "../modules/db"
  public_key_path  = var.public_key_path
  db_disk_image    = var.db_disk_image
  subnet_id        = module.vpc.subnet_id
  stage            = var.stage
  private_key_path = var.private_key_path
  enable_provision = var.enable_provision
  depends_on       = [module.vpc.subnet_id]
}

module "vpc" {
  source   = "../modules/vpc"
  stage    = var.stage
  ip_range = var.ip_range
}

resource "local_file" "generate_inventory" {
  content = templatefile("inventory.tpl", {
    app_name = module.app.name,
    db_name = module.db.name,
    app_ip = module.app.external_ip_address_app,
    db_ip = module.db.external_ip_address_db
  })
  filename = "inventory"

  provisioner "local-exec" {
    command = "chmod a-x inventory && ansible-inventory -i inventory --list > ../../ansible/inventory.json"
  }
}
