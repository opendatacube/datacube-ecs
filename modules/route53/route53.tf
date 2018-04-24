# Simple route53 zone and record for single domain access to the ECS service

data "aws_route53_zone" "selected" {
  name         = "${var.zone_domain_name}"
  private_zone = "${var.private_zone}"
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.domain_name}"
  type    = "${var.record_type}"

  alias {
    name = "${var.target_dns_name}"
    zone_id = "${var.target_dns_zone_id}"
    evaluate_target_health = "${var.evaluate_target_health}"
  }
}