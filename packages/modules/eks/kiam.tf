# Define the role that will be used by the KIAM server nodes

data "aws_iam_policy_document" "kiam_workers_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kiam" {
  name_prefix = "kiam-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.kiam_workers_assume_role_policy.json}"
}

# KIAM nodes are still part of the cluster, so need standard cluster roles
resource "aws_iam_role_policy_attachment" "kiam_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kiam.name}"
}

# Let the KIAM nodes assume roles, the roles that can be assumed will depend
# on the trust policy of the role
data "aws_iam_policy_document" "kiam_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "kiam_assume_role" {
  role = "${aws_iam_role.kiam.name}"
  policy = "${data.aws_iam_policy_document.kiam_assume_role.json}"
}

