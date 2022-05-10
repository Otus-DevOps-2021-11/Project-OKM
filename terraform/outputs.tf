output "k8s_cluster_id" {
 value = yandex_kubernetes_cluster.zonal_cluster_resource_name.id
}

output "disk_for_mongodb_id" {
 value = yandex_compute_disk.disk-for-mongodb.id
}