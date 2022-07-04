terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  cidr = []
}

resource "yandex_vpc_network" "app-network" {
  name = "app-network-${var.stage}"
}

resource "yandex_vpc_subnet" "app-subnet" {
  name           = "app-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.app-network.id
  v4_cidr_blocks = (contains(local.cidr, var.ip_range) == false ? concat(local.cidr, [var.ip_range]) : local.cidr)
}
