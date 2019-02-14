resource "tls_private_key" "kiam_ca" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "kiam_ca" {
  key_algorithm = "${tls_private_key.kiam_ca.algorithm}"
  private_key_pem = "${tls_private_key.kiam_ca.private_key_pem}"

  validity_period_hours = 26280
  early_renewal_hours = 8760

  is_ca_certificate = true

  allowed_uses = ["cert_signing"]

  subject {
    common_name = "kiam-ca"
    organization = "gitops"
    organizational_unit = "${var.environment}"
  }
}

resource "tls_private_key" "kiam_server" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "kiam_server" {
  key_algorithm = "${tls_private_key.kiam_server.algorithm}"
  private_key_pem = "${tls_private_key.kiam_server.private_key_pem}"

  subject {
    common_name = "kiam-server"
    organization = "gitops"
    organizational_unit = "${var.environment}"
  }

  dns_names = [
    "kiam-server",
    "kiam-server:443",
    "localhost",
    "localhost:443",
    "localhost:9610"
  ]
}

resource "tls_locally_signed_cert" "kiam_server" {
  cert_request_pem = "${tls_cert_request.kiam_server.cert_request_pem}"

  ca_key_algorithm = "${tls_private_key.kiam_ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.kiam_ca.private_key_pem}"
  ca_cert_pem = "${tls_self_signed_cert.kiam_ca.cert_pem}"

  validity_period_hours = 1080  # 45 days
  early_renewal_hours = 336     # 14 days

  allowed_uses = ["client_auth", "server_auth", "digital_signature", "key_encipherment"]
}

resource "tls_private_key" "kiam_agent" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "kiam_agent" {
  key_algorithm = "${tls_private_key.kiam_agent.algorithm}"
  private_key_pem = "${tls_private_key.kiam_agent.private_key_pem}"

  subject {
    common_name = "kiam-agent"
    organization = "gitops"
    organizational_unit = "${var.environment}"
  }
}

resource "tls_locally_signed_cert" "kiam_agent" {
  cert_request_pem = "${tls_cert_request.kiam_agent.cert_request_pem}"

  ca_key_algorithm = "${tls_private_key.kiam_ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.kiam_ca.private_key_pem}"
  ca_cert_pem = "${tls_self_signed_cert.kiam_ca.cert_pem}"

  validity_period_hours = 1080  # 45 days
  early_renewal_hours = 336     # 14 days

  allowed_uses = ["client_auth", "server_auth", "digital_signature", "key_encipherment"]
}

data "template_file" "kiam_manifest" {
  template = "${file("${path.module}/manifests/kiam.yml.tpl")}"

  vars = {
    CA_PEM = "${base64encode(tls_self_signed_cert.kiam_ca.cert_pem)}"
    SERVER_PEM = "${base64encode(tls_locally_signed_cert.kiam_server.cert_pem)}"
    SERVER_KEY_PEM = "${base64encode(tls_private_key.kiam_server.private_key_pem)}"
    AGENT_PEM = "${base64encode(tls_locally_signed_cert.kiam_agent.cert_pem)}"
    AGENT_KEY_PEM = "${base64encode(tls_private_key.kiam_agent.private_key_pem)}"
  }
}

resource "local_file" "kiam_manifest" {
  content = "${data.template_file.kiam_manifest.rendered}"
  filename = "${path.module}/manifests/kiam.yml"
}

module "apply" {
    source = "../k8s_apply"

    kubeconfig_file = "${var.kubeconfig_file}"
    path = "${path.module}/manifests/kiam.yml"
    hash = "${base64sha256(data.template_file.kiam_manifest.rendered)}"
}