#Common variables
variable "container_name" {
  type = "string"
  default = "datacube-wms"
  description = "Name of the container targetted by the load balancer"
}

variable "container_port" {
  default = 80
  description = "Port of container targetted by ELB"
}

#Service variables
variable "cluster" {
  type = "string"
  description = "Cluster the ECS service is running on"
}

variable "name" {
  type = "string"
  description = "Name of the ECS service"
}

variable "desired_count" {
  type = "string"
  description = "The desired number of running tasks"
}

variable "target_group_arn" {
  type = "string"
  description = "ARN of the ELB's target group"
}

# Task variables
variable "family" {
  type = "string"
  description = "The family of the task"
}

variable "container" {
  type = "string"
  default = "geoscienceaustralia/datacube-wms:latest"
  description = "Docker container address. e.g. geoscienceaustralia/datacube:latest"
}

variable "memory" {
  default = 1024
  description = "Memory available to container in MiB"
}

variable "container_path" {
  type = "string"
  default = "/opt/data"
  description = "file system path to mounted volume on container. e.g. /opt/data"
}

variable "volume_name" {
  type = "string"
  default = "volume-0"
  description = "name of the volume to be mounted"
}

variable "public_url" {
  type = "string"
  description = "DNS name of the ELB"
}

variable "task_role_arn" {
  type = "string"
  description = "ARN for the role the task will run as"
}

variable "db_admin_password" {
  type = "string"
}