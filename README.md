# GitOps EKS Demo Cluster

Builds an EKS cluster with support for [KIAM](https://github.com/uswitch/kiam) and [Flux](https://github.com/weaveworks/flux).

## Deployment

The deployment uses [Terraform](https://www.terraform.io/) wrapped by [Terragrunt](https://github.com/gruntwork-io/terragrunt).

Terragrunt and per-environment configuration is in the `env/dev/cluster/terraform.tfvars` file.

The Flux instance is currently hard-coded to pull for https://github.com/subnova/k8s-gitops-system.


