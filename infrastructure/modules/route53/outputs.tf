output "fqdn" {
  value = "${var.enable ? element(concat(aws_route53_record.www.*.fqdn, list("")), 0) : ""}"
}