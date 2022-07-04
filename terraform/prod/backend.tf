terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "otus-terra"
    region                      = "ru-central1-a"
    key                         = "prod/terraform.tfstate"
    access_key                  = "<skipped>"
    secret_key                  = "<skipped>"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
