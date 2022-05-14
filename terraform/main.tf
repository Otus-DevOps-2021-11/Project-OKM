terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.token
  #   service_account_id = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "okmacluster"
  description = "OKMA group diplom project"

  network_id = var.network_id

  master {
    version = "1.19"
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.node_service_account_id

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

}

resource "yandex_compute_disk" "disk-for-mongodb" {

  name        = "mongodb-disk"
  size        = "10"
  description = "disk for mongodb"
}

resource "yandex_compute_disk" "disk-for-rabbit" {

  name        = "rabbit-disk"
  size        = "10"
  description = "disk for rabbit"
}