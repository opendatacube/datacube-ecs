variable "name" {
  type        = "string"
  description = "Name of the service"
}

variable "docker_image" {
  type        = "string"
  description = "docker image to run"
}

variable "container_name" {
  type        = "string"
  default     = "datacube-wms"
  description = "Name of the container targetted by the load balancer"
}

variable "container_port" {
  default = 80
}

variable "cpu" {
  default = 1024
}

variable "memory" {
  default     = 1024
  description = "memory for the container in MB"
}

variable "aws_region" {
  type        = "string"
  description = "AWS region for ECS instances"
}

variable "task_desired_count" {
  default     = 1
  description = "Desired count of the ecs task"
}

#######
# Tags
#######

variable "cluster" {
  type        = "string"
  description = "Name of the cluster"
}

variable "workspace" {
  type        = "string"
  description = "workspace of this cluster"
}

variable "owner" {
  type        = "string"
  description = "Owner of this cluster"
}

########
# ecs_policy
########

variable "ssm_decrypt_key" {
  description = "Alias for the ssm decrypt key to access secure ssm parameters"
  default     = "aws/ssm"
}

variable "account_id" {
  description = "The account id for specifying arns"
}

variable "task_role_name" {
  description = "The name of the role"
}

variable "parameter_store_resource" {
  type        = "string"
  default     = "*"
  description = "The parameter store services that can be acccessed. E.g. * for all or /datacube/* for all datacube"
}

########
# ecs_service
########

variable "target_group_arn" {
  type        = "list"
  description = "ARN of the ELB's target group"
}

# Task variables
variable "family" {
  type        = "string"
  description = "The family of the task"
}

variable "container_path" {
  type        = "string"
  default     = "/opt/data"
  description = "file system path to mounted volume on container. e.g. /opt/data"
}

variable "volume_name" {
  type        = "string"
  default     = "volume-0"
  description = "name of the volume to be mounted"
}

variable "container_definitions" {
  type        = "string"
  description = "JSON container definition"
}

variable "webservice" {
  default     = true
  description = "Whether the task should restart and be publically accessible"
}
