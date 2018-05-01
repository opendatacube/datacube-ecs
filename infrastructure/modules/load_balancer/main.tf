# Default ALB implementation that can be used connect ECS instances to it

resource "aws_alb_target_group" "default" {
  # only create if webservice is true
  count                = "${var.webservice}"
  name                 = "${var.alb_name}"
  port                 = "${var.container_port}"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "${var.health_check_path}"
    protocol = "HTTP"
    matcher  = "200-299"
  }

  tags {
    workspace  = "${var.workspace}"
    Cluster    = "${var.cluster}"
    Service    = "${var.service_name}"
    Created_by = "terraform"
    Owner      = "${var.owner}"
  }

  depends_on = ["aws_alb.alb"]
}

resource "aws_alb" "alb" {
  # only create if webservice is true
  count           = "${var.webservice}"
  name            = "${var.alb_name}"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${var.security_group}"]

  tags {
    workspace  = "${var.workspace}"
    Cluster    = "${var.cluster}"
    Service    = "${var.service_name}"
    Created_by = "terraform"
    Owner      = "${var.owner}"
  }
}

resource "aws_alb_listener" "http" {
  # only create if webservice is true
  count             = "${var.webservice}"
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.default"]
}

resource "aws_alb_listener" "https" {
  # only create if webservice and enable_https is true
  count = "${var.enable_https * var.webservice}"

  load_balancer_arn = "${aws_alb.alb.id}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${var.ssl_policy_name}"
  certificate_arn   = "${var.ssl_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.default"]
}
