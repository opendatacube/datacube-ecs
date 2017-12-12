terraform {
  required_version = ">= 0.10.0"

  backend "s3" {
    # This is an s3bucket you will need to create in your aws
    # space
    bucket = "dea-devs-tfstate"

    # The key should be unique to each stack, because we want to
    # have multiple enviornments alongside each other we set
    # this dynamically in the bitbucket-pipelines.yml with the
    # --backend
    key = "ecs-test-stack/"

    encrypt = true

    region = "ap-southeast-2"

    # This is a DynamoDB table with the Primary Key set to LockID
    dynamodb_table = "terraform"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

variable "db_admin_password" {
  description = <<EOF
The password for our database, 
to hide this prompt create an environment variable with the name:

TF_VAR_db_admin_password
  EOF
}

variable "bootstrap_task_name" {
  default = "bootstrap-data"
}

variable "cluster" {
  default = "datacube"
}

variable "bootstrap_compose" {
  default = "docker-compose-bootstrap.yml"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

module "ecs" {
  source = "../terraform-ecs"

  # Tags to apply to the resources
  cluster   = "${var.cluster}"
  workspace = "dev"
  owner     = "YOUR EMAIL HERE"

  timeout = 6

  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  availability_zones    = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  ssh_ip_address        = "0.0.0.0/0"

  # Server Configuration
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  instance_type    = "m4.xlarge"
  ecs_aws_ami      = "ami-c1a6bda2"
  enable_jumpbox   = true

  # create a new ec2-key pair and add it here
  key_name = "ra-tf-dev"

  # Database Configuration
  db_admin_username = "master"
  db_admin_password = "${var.db_admin_password}"
  db_dns_name = "database"
  db_zone = "local"
  db_name = "datacube"

  # Service Configuration
  service_name = "datacube-wms"
  # service_entrypoint = "datacube-wms"
  # service_compose = "docker-compose-aws.yml"
  # custom_script = "export PUBLIC_URL=$${module.load_balancer.alb_dns_name}"
  # health_check_path = "/health"

  container_image = "geoscienceaustralia/datacube-wms:latest"
  task_family = "datacube-task-family"
  task_volume = {
    name = "volume-0",
    host_path = "/opt/data/"
  }
  task_environment_vars = [
      { "name"  = "DB_USERNAME"
        "value" = "master"
      },
      { "name"  = "DB_PASSWORD"
        "value" = "${var.db_admin_password}"
      },
      { "name"  = "DB_DATABASE"
        "value" = "datacube"
      },
      { "name"  = "DB_HOSTNAME"
        "value" = "database.local"
      },
      { "name"  = "DB_PORT"
        "value" = "5432"
      },
      { "name"  = "PUBLIC_URL"
        "value" = "${module.ecs.alb_dns_name}"
      }
  ]

  task_mount_points = [
    {
      "container_path" = "/opt/data/"
      "source_volume"  = "volume-0"
    }
  ]

}

# resource "aws_ecs_task_definition" "datacube-service-task" {
#   family = "datacube-wms-service-task"
#   container_definitions = <<EOF
#   [
#     {
#     "name": "datacube-wms",
#     "image": "geoscienceaustralia/datacube-wms:latest",
#     "memory": 1536,
#     "essential": true,
#     "portMappings": [
#       {
#         "containerPort": 80
#       }
#     ],
#     "mountPoints": [
#       {
#         "containerPath": "/opt/data",
#         "sourceVolume": "volume-0"
#       }
#     ],
#     "environment": [
#       { "name": "DB_USERNAME", "value": "master" },
#       { "name": "DB_PASSWORD", "value": "${var.db_admin_password}" },
#       { "name": "DB_DATABASE", "value": "datacube" },
#       { "name": "DB_HOSTNAME", "value": "database.local" },
#       { "name": "DB_PORT", "value": "5432" },
#       { "name": "PUBLIC_URL", "value": "${module.ecs.alb_load_balancer_dns}"}
#     ]
#   }
# ]
# EOF
#   task_role_arn = "tf_odc_ecs_role"
#   volume {
#     name = "volume-0",
#     host_path = "/opt/data"
#   }
# }

# resource "aws_ecs_service" "datacube-service" {
#   name = "datacube-wms-service"
#   cluster = "${var.cluster}"
#   task_definition = "${aws_ecs_task_definition.datacube-service-task.arn}"
#   desired_count = 6
#   load_balancer {
#     target_group_arn = "${module.ecs.alb_target_group_arn}"
#     container_name = "datacube-wms"
#     container_port = "80"
#   }
# }

output "dns_name" {
  value = "${module.ecs.alb_dns_name}"
}


