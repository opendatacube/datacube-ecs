output "fqdn" {
  value = "${aws_route53_record.www.0.fqdn}"
}