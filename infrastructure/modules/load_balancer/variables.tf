variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer"
}

variable "workspace" {
  description = "The name of the workspace"
}

variable "cluster" {
  description = "The name of the cluster the ecs containers are being deployed into"
}

variable "service_name" {
  description = "The name of the service"
}

variable "owner" {
  description = "A mailing list that owns the service"
}

variable "container_port" {
  description = "The port servicing traffic on the container"
}

variable "security_group" {
  description = "The SG for the ALB"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "List of public subnet ids to place the loadbalancer in"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "deregistration_delay" {
  default     = "30"
  description = "The default deregistration delay"
}

variable "health_check_path" {
  default     = "/"
  description = "The default health check path"
}

variable "allow_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Specify cidr block that is allowed to access the LoadBalancer"
}

variable "enable_https" {
  default     = false
  description = "Specify if this ALB will allow HTTPS"
}

variable "ssl_cert_arn" {
  default     = ""
  description = "If enable_https is true this must be specified"
}

variable "ssl_policy_name" {
  default     = "ELBSecurityPolicy-2016-08"
  description = "The name of the SSL policy for an ALB listener. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies"
}
