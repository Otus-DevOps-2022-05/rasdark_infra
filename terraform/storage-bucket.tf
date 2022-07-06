terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_storage_bucket" "otus-terra" {
  bucket        = var.bucket_name
  force_destroy = "true"
}
