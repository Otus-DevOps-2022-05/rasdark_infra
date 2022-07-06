terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

data "external" "env" {
  program = ["${path.root}/files/env.sh"]
}

data "yandex_compute_image" "db-image" {
  family    = var.db_disk_image
  folder_id = data.external.env.result["folder_id"]
}

resource "yandex_compute_instance" "db" {
  name = "reddit-db-${var.stage}"

  labels = {
    tags = "reddit-db"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db-image.id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

resource "null_resource" "db" {
  count = var.enable_provision ? 1 : 0

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.db.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/mongod.conf.j2", { mongod_ip = yandex_compute_instance.db.network_interface.0.ip_address})
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}
