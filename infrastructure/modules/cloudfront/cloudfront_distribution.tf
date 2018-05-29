# Creates a basic cloudfront disribution with a custom (i.e. not S3) origin

resource "aws_cloudfront_distribution" "cloudfront" {
  count = "${var.enable ? 1 : 0}"

  origin {
    domain_name = "${var.origin_domain}"
    origin_id   = "${var.origin_id}"

    custom_origin_config {
      http_port              = "${var.origin_http_port}"
      https_port             = "${var.origin_https_port}"
      origin_protocol_policy = "${var.origin_protocol_policy}"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = "${var.enable_distribution}"
  is_ipv6_enabled     = "${var.enable_ipv6}"
  default_root_object = ""

  # Yes this is a list of lists now, don't ask
  aliases = ["${var.aliases}"]

  default_cache_behavior {
    allowed_methods  = "${var.default_allowed_methods}"
    cached_methods   = "${var.default_cached_methods}"
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = "${var.min_ttl}"
    max_ttl                = "${var.max_ttl}"
    default_ttl            = "${var.default_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.default.arn}"
    ssl_support_method  = "sni-only"
  }

  price_class = "${var.price_class}"
}

provider "aws" {
  alias  = "cert"
  region = "us-east-1"
}

data "aws_acm_certificate" "default" {
  domain   = "${var.ssl_cert_domain_name}"
  statuses = ["ISSUED"]
  provider = "aws.cert"
  count    = "${var.enable ? 1 : 0}"
}
