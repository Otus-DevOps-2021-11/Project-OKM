output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.zonal_cluster_resource_name.id
}
