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

variable "task_role_arn" {
  type = "string"
  description = "ARN for the role the task will run as"
}

variable "container_definitions" {
  type = "string"
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