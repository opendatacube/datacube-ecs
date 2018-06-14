output "wms_endpoint" {
  value = "${module.route53.fqdn}"
}

output "db" {
  value = "${local.db_ref}"
}
