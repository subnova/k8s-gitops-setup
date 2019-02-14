output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value = "${module.eks.cluster_id}"
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate required to communicate with the cluster"
  value = "${module.eks.cluster_certificate_authority_data}"
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  value = "${module.eks.cluster_endpoint}"
}

output "cluster_version" {
  description = "The Kuberenetes server version for the EKS cluster"
  value = "${module.eks.cluster_version}"
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster"
  value = "${module.eks.kubeconfig}"
}

output "kubeconfig_file" {
  description = "The file containing the kubectl config"
  value = "${var.config_output_path}kubeconfig_${module.eks.cluster_id}"
}

output "worker_security_group_id" {
  description = "The worker security group id"
  value = "${module.eks.worker_security_group_id}"
}

output "kiam_role_arn" {
  description = "The ARN of the role created for the KIAM servers"
  value = "${aws_iam_role.kiam.arn}"
}