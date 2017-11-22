terraform {
  required_version = ">= 0.10.0"

  backend "s3" {
    # This is an s3bucket you will need to create in your aws
    # space
    bucket = "gadevs-tfstate"

    # The key should be unique to each stack, because we want to
    # have multiple enviornments alongside each other we set
    # this dynamically in the bitbucket-pipelines.yml with the
    # --backend
    key = "ecs-test-stack/"

    region = "ap-southeast-2"

    # This is a DynamoDB table with the Primary Key set to LockID
    dynamodb_table = "terraform-lock"
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

module "ecs" {
  source = "github.com/GeoscienceAustralia/terraform-ecs"

  # Tags to apply to the resources
  cluster   = "datacube"
  workspace = "dev"
  owner     = "YOUR EMAIL HERE"

  # Network Configuration
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  availability_zones    = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  ssh_ip_address        = "0.0.0.0/0"

  # Server Configuration
  max_size         = 3
  min_size         = 1
  desired_capacity = 2
  instance_type    = "t2.small"
  ecs_aws_ami      = "ami-c1a6bda2"
  enable_jumpbox   = false

  # create a new ec2-key pair and add it here
  key_name = "gadevs-u16329"

  # Database Configuration
  db_admin_username = "master"
  db_admin_password = "${var.db_admin_password}"
}

output "dns_name" {
  value = "${module.ecs.alb_dns_name}"
}
