module "apply" {
    source = "../k8s_apply"

    kubeconfig_file = "${var.kubeconfig_file}"
    path = "${path.module}/manifests/flux.yml"
}