output "alb_target_group" {
  value = "${aws_alb_target_group.default.*.arn}"
}

output "alb_dns_name" {
  value = "${aws_alb.alb.*.dns_name}"
}

output "alb_dns_zone_id" {
  value = "${aws_alb.alb.*.zone_id}"
}

output "alb_name" {
  value = "${var.alb_name}"
}
