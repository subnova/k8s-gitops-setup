variable "environment" {
    description = "The name of the environment being deployed"
}

variable "kubeconfig_file" {
    description = "The location of the kubernetes config file"
}

variable "kiam_role_arn" {
    description = "The ARN of the role associated with the KIAM servers"
}