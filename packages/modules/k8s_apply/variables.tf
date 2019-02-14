variable "path" {
    description = "The path to the file containing the kubernetes manifests to apply"
}

variable "hash" {
    description = "The hash of the content"
}

variable "kubeconfig_file" {
    description = "The location of the kubernetes config file"
}
