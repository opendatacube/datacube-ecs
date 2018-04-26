variable "name" {
  type        = "string"
  description = "Name of the service"
}

variable "docker_image" {
  type        = "string"
  description = "docker image to run"
}

variable "zone_url" {
  type        = "string"
  description = "Zone URL"
}

variable "public_url" {
  type        = "string"
  description = "The URL at which this service will be accessed"
}

variable "database" {
  type        = "string"
  description = "name of the database being used"
}

variable "db_username" {
  type        = "string"
  description = "database admin username"
}

variable "db_zone" {
  type        = "string"
  description = "database DNS zone"
}

variable "db_name" {
  type        = "string"
  description = "database DNS name"
}

variable "container_name" {
  type        = "string"
  default     = "datacube-wms"
  description = "Name of the container targetted by the load balancer"
}

variable "container_port" {
  default = 80
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

## ALB required vars

variable "alb_name" {
  type        = "string"
  description = "unique name for the alb"
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the VPC this ALB is contained in"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "IDs of the public subnets that this ALB will use"
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

# Dummy variable to emulate a depends_on
variable depends_on {
  default = []
  type    = "list"
}

########
# ecs_service
########

variable "target_group_arn" {
  type        = "string"
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

  # example JSON string
  #   <<EOF
  #   [
  #     {
  #     "name": "${var.container_name}",
  #     "image": "${var.container}",
  #     "memory": ${var.memory},
  #     "essential": true,
  #     "portMappings": [
  #       {
  #         "containerPort": ${var.container_port}
  #       }
  #     ],
  #     "mountPoints": [
  #       {
  #         "containerPath": "${var.container_path}",
  #         "sourceVolume": "${var.volume_name}"
  #       }
  #     ],
  #     "environment": [
  #       { "name": "DB_USERNAME", "value": "master" },
  #       { "name": "DB_PASSWORD", "value": "${var.db_admin_password}" },
  #       { "name": "DB_DATABASE", "value": "datacube" },
  #       { "name": "DB_HOSTNAME", "value": "database.local" },
  #       { "name": "DB_PORT", "value": "5432" },
  #       { "name": "PUBLIC_URL", "value": "${var.public_url}"}
  #     ]
  #   }
  # ]
  # EOF
}

# variable "cpu" {
#   type = "string"
#   default = 1024
# }


# variable "cpu" {
#   type = "string"
#   default = 1024
# }


# variable "launch_type" {
#   type = "string"
#   default = "FARGATE"
# }

