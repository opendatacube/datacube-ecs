# --------------
# Variables

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "db_port" {
  default = 5432
}

variable "cluster" {}

variable "workspace" {}

variable "name" {}

variable "db_host" {}

variable "db_admin_user" {}

variable "db_admin_pass" {}

variable "database" {}

# --------------
# AWS
provider "aws" {
  region = "${var.aws_region}"
}

locals {
  db_name = "${var.cluster}-${var.workspace}-${var.name}-db"
  db_user = "${var.cluster}_${var.workspace}_${var.name}_user"
}

resource "aws_ssm_parameter" "service_db_name" {
  name      = "${var.cluster}.${var.workspace}.${var.name}.service_db_name"
  value     = "${local.db_name}"
  type      = "String"
  overwrite = false
}

resource "aws_ssm_parameter" "service_db_username" {
  name      = "${var.cluster}.${var.workspace}.${var.name}.service_db_username"
  value     = "${local.db_user}"
  type      = "String"
  overwrite = false
}

resource "random_string" "password" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "service_db_password" {
  name      = "${var.cluster}.${var.workspace}.${var.name}.service_db_password"
  value     = "${random_string.password.result}"
  type      = "String"
  overwrite = false
}

# -------------
# Postgres

provider "postgresql" {
  host     = "${var.db_host}"
  port     = "${var.db_port}"
  username = "${var.db_admin_user}"
  password = "${var.db_admin_pass}"
}

resource "postgresql_role" "my_role" {
  name     = "${local.db_user}"
  login    = true
  password = "${local.db_pass}"
}

resource "postgresql_database" "my_db" {
  name              = "${var.database}"
  owner             = "${local.db_user}"
  connection_limit  = -1
  allow_connections = true
}

# -------------
# Variables
resource "null_resource" "env_vars" {
  triggers {
    db_user = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "firsttime/setup.sh"

    # This will add environment vars to any already set
    environment = {
      DB_HOSTNAME = "${var.db_host}"
      DB_PORT     = "${var.db_port}"
      DB_USERNAME = "${local.db_user}"
      DB_PASSWORD = "${local.db_pass}"
      DB_DATABASE = "${var.database}"
    }
  }
}
