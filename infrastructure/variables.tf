variable "cluster" {
  default     = "datacube-wms"
  description = "The name of the cluster you created using the terraform-ecs repo"
}

variable "aws_region" {
  default     = "ap-southeast-2"
  description = "The region you are deploying in"
}

variable "workspace" {
  default     = "dev"
  description = "The name of this workspace - used to seperate resources"
}

variable "owner" {
  default     = "DEA"
  description = "The name of the team that manages this service - used to tag resources"
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
  description = "A docker image to run"
}

variable "docker_command" {
  default     = ""
  description = "Command to run on docker container"
}

variable "health_check_path" {
  default     = "/?version=1.3.0&request=GetCapabilities&service=WMS"
  description = "A path that returns 200 OK if container is healthy"
}

variable "memory" {
  default     = 1024
  description = "Memory for the container in MB"
}

variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer to create"
}

# ==================
# Containers
variable "container_port" {
  default     = 8000
  description = "The port our container is listening on"
}

variable "environment_vars" {
  default     = {}
  description = "Map containing environment variables to pass to docker container. Overrides defaults."
}

variable "custom_policy" {
  default     = ""
  description = "IAM Policy JSON to be added to the task policy"
}

# ==================
# Services and Tasks
variable "task_desired_count" {
  default     = 1
  description = "The number of tasks we want to run"
}

variable "schedulable" {
  default     = false
  description = "Should this task be run on a regular schedule"
}

variable "schedule_expression" {
  default     = ""
  description = "AWS Cron or Rate expression"
}

# ==================
# Database

variable "database" {
  default     = ""
  description = "The name of the database"
}

# ==================
# DNS

variable "dns_name" {
  default     = ""
  description = "DNS name of the service"
}

variable "dns_zone" {
  default     = ""
  description = "Overwrites the cluster DNS zone"
}

# ==================
# HTTPS

variable "enable_https" {
  default     = false
  description = "Should HTTPS be enabled (and forced)"
}

variable "ssl_cert_region" {
  default     = "us-east-1"
  description = "If SSL is enabled, the region the certificates exist in"
}

variable "ssl_cert_domain_name" {
  default     = ""
  description = "Overwrites the cluster default wildcard cert"
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
  description = "Whether we should create a database and initialise datacube"
}

variable "new_database_name" {
  default     = ""
  description = "If this is a datasbase task we will create a new db with this name"
}
