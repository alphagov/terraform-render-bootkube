resource "tls_private_key" "iam-authenticator" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "iam-authenticator" {
  key_algorithm   = "${tls_private_key.iam-authenticator.algorithm}"
  private_key_pem = "${tls_private_key.iam-authenticator.private_key_pem}"

  subject {
    common_name = "aws-iam-authenticator"
  }

  dns_names = [
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1",
  ]
}

resource "tls_locally_signed_cert" "iam-authenticator" {
  cert_request_pem = "${tls_cert_request.iam-authenticator.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_certificate == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_private_key}"
  ca_cert_pem        = "${var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem): var.ca_certificate}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}
