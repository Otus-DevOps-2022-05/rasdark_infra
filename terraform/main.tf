#terraform {
#  required_providers {
#    yandex = {
#      source = "yandex-cloud/yandex"
#    }
#  }
#}

provider "yandex" {
#  version   = 0.35
  service_account_key_file = var.service_account_key_file
  cloud_id  = "b1gid4vroi4t53jgmlpj"
  folder_id = "b1gqpofo13bvldc6bvi4"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "reddit" {
  family = "reddit-base"
  folder_id = "b1gqpofo13bvldc6bvi4"
}

resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  resources {
    cores = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.reddit.id
    }
  }
  network_interface {
    subnet_id = "e9b9sjojl033kbun3gsj"
    nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/appuser.pub")}"
  }

  provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

  connection {
      type = "ssh"
      host = yandex_compute_instance.app.network_interface.0.nat_ip_address
      user = "ubuntu"
      agent = false
      private_key = file("~/.ssh/appuser")
  }
}
