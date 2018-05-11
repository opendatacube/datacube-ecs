variable "domain_name" {
  type = "string"
  description = "The desired domain name e.g. wms.datacube.org.au"
}

variable "zone_domain_name" {
  type = "string"
  description = "Domain name of the route53 zone. Generally the base domain e.g. datacube.org.au"
}

variable "private_zone" {
  default = false
  description = "Determines whether this is for private VPC DNS zones"
}

variable "record_type" {
  type = "string"
  default = "A"
  description = "The DNS record type"
}

variable "target_dns_name" {
  type = "string"
  description = "The DNS name of the target e.g. the ALB or EC2 instance"
}

variable "target_dns_zone_id" {
  type = "string"
  description = "The DNS zone of the target"
}

variable "evaluate_target_health" {
  default = true
  description = "If true, Route53 will health check the target before routing traffic to it"
}

variable "enable" {
  default = false
  description = "Whether to create route53 entry or not"
}