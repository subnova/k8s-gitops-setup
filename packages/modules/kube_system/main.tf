module "apply" {
    source = "../k8s_apply"

    kubeconfig_file = "${var.kubeconfig_file}"
    path = "${path.module}/manifests/ns.yml"
    hash = "${base64sha256(file("${path.module}/manifests/ns.yml"))}"
}