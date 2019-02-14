#https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/

locals {
    cidr = "10.0.0.0/16"
    public_subnets = ["${cidrsubnet(local.cidr, 8, 0)}", "${cidrsubnet(local.cidr, 8, 1)}", "${cidrsubnet(local.cidr, 8, 2)}"]
    private_subnets = ["${cidrsubnet(local.cidr, 8, 4)}", "${cidrsubnet(local.cidr, 8, 5)}", "${cidrsubnet(local.cidr, 8, 6)}"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}"
  cidr = "${local.cidr}"

  azs             = ["${var.availability_zones}"]
  public_subnets  = ["${slice(local.public_subnets, 0, length(var.availability_zones))}"]
  private_subnets = ["${slice(local.private_subnets, 0, length(var.availability_zones))}"]

  public_subnet_tags = {
    Name = "${var.environment}-public"
  }

  private_subnet_tags = {
    Name = "${var.environment}-private"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "${var.environment}"
    Component   = "cluster"
  }
}

module "eks" {
    source = "../modules/eks"

    environment = "${var.environment}"
    aws_region = "${var.aws_region}"
    availability_zones = "${var.availability_zones}"
    vpc_id = "${module.vpc.vpc_id}"
    worker_subnets = ["${module.vpc.private_subnets}"]
    config_output_path = "/tmp/"
}

module "flux" {
    source = "../modules/flux"

    kubeconfig_file = "${module.eks.kubeconfig_file}"
}

module "kiam" {
    source = "../modules/kiam"

    environment = "${var.environment}"
    kubeconfig_file = "${module.eks.kubeconfig_file}"
    kiam_role_arn = "${module.eks.kiam_role_arn}"
}