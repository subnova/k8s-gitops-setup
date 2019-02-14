locals {
  worker_groups = [
    {
      asg_desired_capacity = "1"
      asg_min_size = 0
      asg_max_size = 4
      instance_type = "t3.medium"
      name = "gp-${element(var.availability_zones, 0)}-"
      subnets = "${element(var.worker_subnets, 0)}"
      autoscaling_enabled = true
      kubelet_extra_args = "--node-labels workload=gp"
    },
    {
      asg_desired_capacity = "1"
      asg_min_size = 0
      asg_max_size = 4
      instance_type = "t3.medium"
      name = "gp-${element(var.availability_zones, 1)}-"
      subnets = "${element(var.worker_subnets, 1)}"
      autoscaling_enabled = true
      kubelet_extra_args = "--node-labels workload=gp"
    },
    {
      asg_desired_capacity = "1"
      asg_min_size = 0
      asg_max_size = 4
      instance_type = "t3.medium"
      name = "gp-${element(var.availability_zones, 2)}-"
      subnets = "${element(var.worker_subnets, 2)}"
      autoscaling_enabled = true
      kubelet_extra_args = "--node-labels workload=gp"
    },
    {
      asg_desired_capacity = 2
      asg_min_size = 1
      asg_max_size = 4
      instance_type = "t3.medium"
      name = "kiam-"
      subnets = "${join(",", var.worker_subnets)}"
      kubelet_extra_args = "--register-with-taints workload=kiam:NoSchedule --node-labels workload=kiam"
      iam_role_id = "${aws_iam_role.kiam.id}"
    }
  ]

  worker_group_count = "4"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = "gitops-${var.environment}"
  subnets = ["${var.worker_subnets}"]
  vpc_id = "${var.vpc_id}"

  worker_groups = "${local.worker_groups}"
  worker_group_count = "${local.worker_group_count}"

  config_output_path = "${var.config_output_path}"

  tags = {
    Environment = "${var.environment}"
  }
}
