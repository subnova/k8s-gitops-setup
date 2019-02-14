resource "null_resource" "eks_worker_bouncer" {
  count = "${local.worker_group_count}"

  triggers {
    worker_groups_change = "${jsonencode(local.worker_groups[count.index])}"
  }

  provisioner "local-exec" {
    command = "${path.module}/bouncerw canary -a '${element(module.eks.workers_asg_names, count.index)}':${lookup(local.worker_groups[count.index], "asg_desired_capacity")}"
  
    environment {
      AWS_DEFAULT_REGION = "${var.aws_region}"
    }
  }
}

