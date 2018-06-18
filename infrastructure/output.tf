output "wms_endpoint" {
  value = "${module.route53.fqdn}"
}

output "alb_endpoint" {
  value = "${element(concat(module.alb.dns_name, list("")), 0)}"
}

output "db" {
  value = "${local.db_ref}"
}
