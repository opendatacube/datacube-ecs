output "alb_target_group" {
  value = "${aws_alb_target_group.default.*.arn}"
}

output "dns_name" {
  value = "${aws_alb.alb.*.dns_name}"
}

output "dns_zone_id" {
  value = "${aws_alb.alb.*.zone_id}"
}

output "alb_name" {
  value = "${var.alb_name}"
}
