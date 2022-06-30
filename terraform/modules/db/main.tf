data "yandex_compute_image" "db-image" {
  family    = var.db_disk_image
  folder_id = var.folder_id
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
