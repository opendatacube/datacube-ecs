variable "cluster" {
  default = "datacube-wms"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "workspace" {
  default = "dev"
}

variable "owner" {
  default = "DEA"
}

variable "name" {
  type        = "string"
  description = "Name of the service"
}

variable "webservice" {
  default     = true
  description = "Whether the task should restart and be publically accessible"
}

variable "docker_image" {
  type        = "string"
  description = "docker image to run"
}

variable "docker_command" {
  default     = ""
  description = "Command to run on docker container"
}

variable "health_check_path" {
  default     = "/?version=1.3.0&request=GetCapabilities&service=WMS"
  description = "A path that returns 200OK if container is healthy"
}

variable "memory" {
  default     = 1024
  description = "memory for the container in MB"
}

variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer"
}

# ==================
# Containers
variable "container_port" {
  default = 8000
}

variable "environment_vars" {
  default     = {}
  description = "Map containing environment variables to pass to docker container. Overrides defaults."
}

variable "custom_policy" {
  default     = ""
  description = "IAM Policy JSON"
}

# ==================
# Services and Tasks
variable "task_desired_count" {
  default = 1
}

variable "schedulable" {
  default = false
}

variable "schedule_expression" {
  default = ""
}

# ==================
# Database

variable "database" {
  default = ""
}

# ==================
# DNS

variable "dns_name" {
  default     = ""
  description = "DNS name of the service"
}

variable "dns_zone" {
  default     = ""
  description = "DNS zone of the service"
}

# ==================
# HTTPS

variable "enable_https" {
  default = false
}

variable "ssl_cert_region" {
  default     = "us-east-1"
  description = "If SSL is enabled, the region the certificates exist in"
}

variable "ssl_cert_domain_name" {
  default     = ""
  description = "If SSL is enabled, the domain name of the certificate to be used"
}

# ==================
# Cloudfront

variable "use_cloudfront" {
  default = true
  description = "If true, will create a Cloudfront distribution. Must be used with webservice=true"
}

# ==================
# DB Task

variable "database_task" {
  default     = false
  description = "Whether we should create database setup specific resources"
}

variable "new_database_name" {
  default     = ""
  description = "If this is a datasbase task we will create a new db with this name"
}
