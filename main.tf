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
    key = "s2-indexing-test-stack-southeast-2/"

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
  name = "geoscienceaustralia/datacube-wms:crcsi"
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
  base_url = "opendatacubes.com"

  # url that points to the service
  public_url = "s2-wms.${local.base_url}"
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
  ec2_security_group = "${module.ec2_instances.ecs_instance_security_group_id}"

  zone_url   = "${local.base_url}"
  public_url = "${local.public_url}"
  aws_region = "${var.aws_region}"

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

resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster}"
}

module "vpc" {
  source = "../terraform-ecs/modules/vpc"

  cidr = "${var.vpc_cidr}"

  # Tags
  workspace = "${var.workspace}"
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
}

module "public" {
  source = "../terraform-ecs/modules/public_layer"

  # Networking
  vpc_id               = "${module.vpc.id}"
  vpc_igw_id           = "${module.vpc.igw_id}"
  availability_zones   = "${var.availability_zones}"
  public_subnet_cidrs  = "${var.public_subnet_cidrs}"
  private_subnet_cidrs = "${var.private_subnet_cidrs}"

  # Jumpbox
  ssh_ip_address = "${var.ssh_ip_address}"
  key_name       = "${var.key_name}"
  jumpbox_ami    = "${data.aws_ami.jumpbox_ami.image_id}"
  enable_jumpbox = "${var.enable_jumpbox}"

  # NAT
  enable_nat      = "${var.enable_nat}"
  enable_gateways = "${var.enable_gateways}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}

module "database" {
  source = "../terraform-ecs/modules/database_layer"

  # Networking
  vpc_id                = "${module.vpc.id}"
  availability_zones    = "${var.availability_zones}"
  ecs_instance_sg_id    = "${module.ec2_instances.ecs_instance_security_group_id}"
  jump_ssh_sg_id        = "${module.public.jump_ssh_sg_id}"
  database_subnet_cidrs = "${var.database_subnet_cidrs}"

  # DB params
  db_admin_username = "${var.db_admin_username}"
  db_admin_password = "${var.db_admin_password}"
  dns_name          = "${var.db_dns_name}"
  zone              = "${var.db_zone}"
  db_name           = "${var.db_name}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}

module "ec2_instances" {
  source = "../terraform-ecs/modules/ec2_instances"

  # EC2 Parameters
  instance_group   = "datacubewms"
  instance_type    = "t2.medium"
  max_size         = "2"
  min_size         = "1"
  desired_capacity = "2"
  aws_ami          = "${data.aws_ami.node_ami.image_id}"

  # Networking
  vpc_id                = "${module.vpc.id}"
  key_name              = "${var.key_name}"
  jump_ssh_sg_id        = "${module.public.jump_ssh_sg_id}"
  nat_ids               = "${module.public.nat_ids}"
  nat_instance_ids      = "${module.public.nat_instance_ids}"
  availability_zones    = "${var.availability_zones}"
  private_subnet_cidrs  = "${var.private_subnet_cidrs}"
  container_port        = "${var.container_port}"
  alb_security_group_id = "${list(module.ecs_main.alb_security_group_id)}"

  # If EFS is being used create the module and uncomment the efs_id
  use_efs = false

  # efs_id                = "${module.efs.efs_id}"

  # NAT
  enable_nat = "${var.enable_nat}"
  # Force dependency wait
  depends_id = "${module.public.nat_complete}"
  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
  aws_region = "${var.aws_region}"
}

# Cloudfront distribution
module "cloudfront" {
  source = "modules/cloudfront"

  origin_domain = "${module.ecs_main.alb_dns_name}"
  origin_id     = "default_lb_origin"
}

# Route 53 address for this cluster
module "route53" {
  source = "../../../terraform-ecs/modules/route53"

  zone_domain_name   = "${local.zone_url}"
  domain_name        = "${local.public_url}"
  target_dns_name    = "${module.cloudfront.domain_name}"
  target_dns_zone_id = "${module.cloudfront.hosted_zone_id }"
}
