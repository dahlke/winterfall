output "k8s_cluster_endpoint" {
  value = "${module.eks-cluster.cluster_endpoint}"
}

output "k8s_cert_auth_data" {
  value = "${module.eks-cluster.cluster_certificate_authority_data}"
}

output "k8s_cluster_name" {
  value = "${var.project_name}"
}
