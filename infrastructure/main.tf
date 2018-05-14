terraform {
  required_version = ">= 0.10.0"

  backend "s3" {
    # Force encryption
    encrypt = true
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
  name = "${var.docker_image}"
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

  public_subnet_ids = ["${data.aws_subnet.a.id}", "${data.aws_subnet.b.id}", "${data.aws_subnet.c.id}"]

  default_environment_vars = {
    "DATACUBE_CONFIG_PATH" = "/opt/odc/datacube.conf"
    "DB_HOSTNAME"          = "${data.aws_ssm_parameter.db_host.value}"
    "DB_USERNAME"          = "${data.aws_ssm_parameter.db_username.value}"
    "DB_PASSWORD"          = "${data.aws_ssm_parameter.db_password.value}"
    "DB_DATABASE"          = "${data.aws_ssm_parameter.db_name.value}"
    "DB_PORT"              = "5432"
    "VIRTUAL_HOST"         = "localhost,127.0.0."
  }

  env_vars = "${merge(local.default_environment_vars, var.environment_vars)}"
}

module "container_def" {
  source = "github.com/eiara/terraform_container_definitions"

  name      = "${var.name}"
  image     = "${var.docker_image}"
  essential = true
  memory    = "${var.memory}"

  logging_driver = "awslogs"

  logging_options = {
    "awslogs-region" = "${var.aws_region}"
    "awslogs-group"  = "${var.cluster}/${var.workspace}/${var.name}"
  }

  port_mappings = [{
    "container_port" = "${var.container_port}"
  }]

  environment = "${local.env_vars}"
  command     = ["${compact(split(" ",var.docker_command))}"]
}

module "ecs_main" {
  source = "modules/ecs"

  name         = "${var.name}"
  docker_image = "${module.docker_help.name_and_digest_ecs}"

  memory             = "768"
  container_port     = "${var.container_port}"
  container_name     = "${var.name}"
  task_desired_count = "${var.task_desired_count}"

  aws_region = "${var.aws_region}"

  family = "${var.name}-service-task"

  task_role_name   = "${var.name}-role"
  target_group_arn = "${module.alb.alb_target_group}"
  account_id       = "${data.aws_caller_identity.current.account_id}"
  webservice       = "${var.webservice}"

  # // container def
  container_definitions = "[${module.container_def.json}]"
  custom_policy         = "${var.custom_policy}"

  # Scheduling definitions
  schedulable         = "${var.schedulable}"
  schedule_expression = "${var.schedule_expression}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}

module "alb" {
  source = "modules/load_balancer"

  workspace         = "${var.workspace}"
  cluster           = "${var.cluster}"
  owner             = "${var.owner}"
  service_name      = "${var.name}"
  vpc_id            = "${data.aws_vpc.cluster.id}"
  public_subnet_ids = "${local.public_subnet_ids}"
  alb_name          = "${var.alb_name}"
  container_port    = "${var.container_port}"
  security_group    = "${data.aws_security_group.alb_sg.id}"
  health_check_path = "${var.health_check_path}"
  webservice        = "${var.webservice}"
}


# Lack of a module count means we need to use flags
# and counts inside the route53 module to conditionally
# create the resources.
# Terraform doesn't lazily evaluate conditional expressions
# we have to ensure there is something in the list for
# terraform to not complain about an empty list, even if webservice is false
module "route53" {
  source = "modules/route53"

  domain_name        = "${var.dns_name}"
  zone_domain_name   = "${var.dns_zone}"
  target_dns_name    = "${var.webservice ? element(concat(module.alb.alb_dns_name, list("")), 0) : ""}"
  target_dns_zone_id = "${var.webservice ? element(concat(module.alb.alb_dns_zone_id, list("")), 0) : ""}"
  enable             = "${var.webservice}"
}

# Lack of a module count means we need to use flags
# and counts inside the cloudfront module to conditionally
# create the resources.
# Terraform doesn't lazily evaluate conditional expressions
# we have to ensure there is something in the list for
# terraform to not complain about an empty list, even if webservice is false
# module "cloudfront" {
#   source = "modules/cloudfront"

#   origin_domain = "${var.webservice ? element(concat(module.alb.alb_dns_name, list("")), 0) : ""}"
#   origin_id     = "${var.cluster}_${var.workspace}_${var.name}_origin"
#   aliases       = ["${var.dns_name}"]
#   enable        = "${var.webservice}"
# }


# ==============
# Ancilliary

provider "aws" {
  region = "ap-southeast-2"
}


