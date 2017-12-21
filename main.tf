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
    key = "ecs-test-stack-southeast-1/"

    encrypt = true

    region = "ap-southeast-1"

    # This is a DynamoDB table with the Primary Key set to LockID
    dynamodb_table = "terraform"
  }
}

# ===============
# services


module "prod_service" {
  source = "../terraform-ecs/modules/ecs"

  name    = "datacube-wms"
  cluster = "${var.cluster}"
  family  = "datacube-wms-service-task"

  desired_count = "${var.task_desired_count}"

  task_role_arn    = "${module.ecs_policy.role_arn}"
  target_group_arn = "${module.alb_test.alb_target_group}"

  # // container def
  container_definitions = <<EOF
  [
    {
    "name": "datacube-wms",
    "image": "geoscienceaustralia/datacube-wms:latest",
    "memory": 1024,
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
      { "name": "DB_USERNAME", "value": "${var.db_admin_username}" },
      { "name": "DB_PASSWORD", "value": "${var.db_admin_password}" },
      { "name": "DB_DATABASE", "value": "datacube" },
      { "name": "DB_HOSTNAME", "value": "${var.db_dns_name}.${var.db_zone}" },
      { "name": "DB_PORT"    , "value": "5432" },
      { "name": "PUBLIC_URL" , "value": "${module.alb_test.alb_dns_name}"}
    ]
  }
]
EOF

}

module "test_service" {
  source = "../terraform-ecs/modules/ecs"

  name    = "datacube-wms-2"
  cluster = "${var.cluster}"
  family  = "datacube-wms-service-task-2"

  desired_count = "${var.task_desired_count}"

  task_role_arn    = "${module.ecs_policy.role_arn}"
  target_group_arn = "${module.alb_test_2.alb_target_group}"
  
  container_definitions = <<EOF
  [
    {
    "name": "datacube-wms",
    "image": "geoscienceaustralia/datacube-wms:fc_test",
    "memory": 1024,
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
      { "name": "DB_USERNAME", "value": "${var.db_admin_username}" },
      { "name": "DB_PASSWORD", "value": "${var.db_admin_password}" },
      { "name": "DB_DATABASE", "value": "datacube" },
      { "name": "DB_HOSTNAME", "value": "${var.db_dns_name}.${var.db_zone}" },
      { "name": "DB_PORT"    , "value": "5432" },
      { "name": "PUBLIC_URL" , "value": "${module.alb_test.alb_dns_name}"}
    ]
  }
]
EOF
}

# ==============
# Load balancers

module "alb_test" {
  source = "../terraform-ecs/modules/load_balancer"

  workspace         = "${var.workspace}"
  cluster           = "${var.cluster}"
  owner             = "${var.owner}"
  service_name      = "datacube-wms"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.public.public_subnet_ids}"
  alb_name          = "alb-test-1"
  container_port    = "${var.container_port}"
  health_check_path = "/health"
}

module "alb_test_2" {
  source = "../terraform-ecs/modules/load_balancer"

  workspace         = "${var.workspace}"
  cluster           = "${var.cluster}"
  owner             = "${var.owner}"
  service_name      = "datacube-wms-2"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.public.public_subnet_ids}"
  alb_name          = "alb-test-2"
  container_port    = "${var.container_port}"
  health_check_path = "/health"
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
  vpc_id              = "${module.vpc.id}"
  vpc_igw_id          = "${module.vpc.igw_id}"
  availability_zones  = "${var.availability_zones}"
  public_subnet_cidrs = "${var.public_subnet_cidrs}"
  public_subnet_count = "${length(var.public_subnet_cidrs)}"

  # Jumpbox
  ssh_ip_address = "${var.ssh_ip_address}"
  key_name       = "${var.key_name}"
  jumpbox_ami    = "${data.aws_ami.jumpbox_ami.image_id}"
  enable_jumpbox = true

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
  instance_group    = "datacubewms"
  instance_type     = "m4.xlarge"
  max_size          = "2"
  min_size          = "1"
  desired_capacity  = "1"
  aws_ami           = "${data.aws_ami.node_ami.image_id}"

  # Networking
  vpc_id                = "${module.vpc.id}"
  key_name              = "${var.key_name}"
  jump_ssh_sg_id        = "${module.public.jump_ssh_sg_id}"
  nat_ids               = "${module.public.nat_ids}"
  availability_zones    = "${var.availability_zones}"
  private_subnet_cidrs  = "${var.private_subnet_cidrs}"
  container_port        = "${var.container_port}"
  alb_security_group_id = "${list(module.alb_test.alb_security_group_id, module.alb_test_2.alb_security_group_id)}"

  # Force dependency wait
  depends_id = "${module.public.nat_complete}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"

  aws_region = "${var.aws_region}"
}

module "ecs_policy" {
  source = "../terraform-ecs/modules/ecs_policy"

  task_role_name = "datacube-wms-role"

  account_id         = "${data.aws_caller_identity.current.account_id}"
  aws_region         = "${var.aws_region}"
  ec2_security_group = "${module.ec2_instances.ecs_instance_security_group_id}"

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster}"
  workspace = "${var.workspace}"
}