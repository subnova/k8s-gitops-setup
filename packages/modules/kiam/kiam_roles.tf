data "aws_iam_policy_document" "kiam_assume" {
  statement {
    sid = "KIAM"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "${var.kiam_role_arn}"
      ]
    }
  }
}

# External DNS
resource "aws_iam_role" "external_dns" {
  name = "external-dns-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.kiam_assume.json}"
}

resource "aws_iam_role_policy" "kiam_external_dns" {
  role = "${aws_iam_role.external_dns.name}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

# Cert Manager
resource "aws_iam_role" "cert_manager" {
  name = "cert-manager-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.kiam_assume.json}"
}

resource "aws_iam_role_policy" "cert_manager" {
  role = "${aws_iam_role.cert_manager.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
EOF
} 
