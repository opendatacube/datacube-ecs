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
  default     = "YOUR-EMAIL"
}

variable "container_port" {
  description = "The port servicing traffic on the container"
  default = 80
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
  default     = "/health"
  description = "The default health check path"
}

variable "allow_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Specify cidr block that is allowed to access the LoadBalancer"
}
