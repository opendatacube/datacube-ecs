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
    key = "datacube-ecs-test/terraform.tfstate"

    encrypt = true

    region = "ap-southeast-2"

    # This is a DynamoDB table with the Primary Key set to LockID
    dynamodb_table = "terraform"
  }
}

# ===============
# containers
# ===============
# docker containers used in the WMS
# given in the format name:tag
# code will extract the SHA256 hash to allow Terraform
# to update a task definition to an exact version
# This means that running Terraform after a docker image
# changes, the task will be updated.
data "docker_registry_image" "latest" {
  name = "geoscienceaustralia/datacube-wms:latest"
}

module "docker_help" {
  source = "modules/docker"

  image_name   = "${data.docker_registry_image.latest.name}"
  image_digest = "${data.docker_registry_image.latest.sha256_digest}"
}

# ===============
# public address
# ===============
# set the public URL information here

locals {
  # base url that corresponds to the Route53 zone
  base_url = "dea.gadevs.ga"
  # url that points to the service
  public_url = "datacube-wms.${local.base_url}"
}

module "ecs_main" {
  source = "modules/ecs"

  name         = "datacube-wms"
  docker_image = "${module.docker_help.name_and_digest_ecs}"

  memory         = "768"
  container_port = "${var.container_port}"

  alb_name          = "datacube-wms-loadbalancer"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.public.public_subnet_ids}"

  db_name     = "${var.db_dns_name}"
  db_zone     = "${var.db_zone}"
  db_username = "${var.db_admin_username}"
  database    = "datacube"

  task_desired_count = "${var.task_desired_count}"


  zone_url   = "${local.base_url}"
  public_url = "${local.public_url}"
  aws_region = "${var.aws_region}"

  family  = "${var.name}-service-task"

  task_role_arn    = "${module.ecs.role_arn}"
  target_group_arn = "${module.alb.alb_target_group}"
  task_role_name   = "${var.name}-role"

  account_id         = "${data.aws_caller_identity.current.account_id}"
  ec2_security_group = "${var.ec2_security_group}"

  # // container def
  container_definitions = <<EOF
[
  {
  "name": "${var.name}",
  "image": "${var.docker_image}",
  "memory": ${var.memory},
  "essential": true,
  "portMappings": [
    {
      "containerPort": ${var.container_port}
    }
  ],
  "mountPoints": [
    {
      "containerPath": "/opt/data",
      "sourceVolume": "volume-0"
    }
  ],
  "environment": [
    { "name": "DB_USERNAME", "value": "${var.db_username}" },
    { "name": "DB_DATABASE", "value": "${var.database}" },
    { "name": "DB_HOSTNAME", "value": "${var.db_name}.${var.db_zone}" },
    { "name": "DB_PORT"    , "value": "5432" },
    { "name": "PUBLIC_URL" , "value": "${var.public_url}"}
  ]
}
]
EOF
}


  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}

# ==============
# Ancilliary

provider "aws" {
  region = "ap-southeast-2"
}

# Cloudfront distribution
module "cloudfront" {
  source = "modules/cloudfront"

  origin_domain = "${module.ecs_main.alb_dns_name}"
  origin_id     = "default_lb_origin"
}

# Route 53 address for this cluster
module "route53" {
  source = "modules/route53"

  zone_domain_name   = "${local.zone_url}"
  domain_name        = "${local.public_url}"
  target_dns_name    = "${module.cloudfront.domain_name}"
  target_dns_zone_id = "${module.cloudfront.hosted_zone_id }"
}
