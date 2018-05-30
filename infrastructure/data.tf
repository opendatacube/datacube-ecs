#--------------------------------------------------------------
# Account ID
#--------------------------------------------------------------

# Get the AWS account ID so we can use it in IAM policies

data "aws_caller_identity" "current" {}

#--------------------------------------------------------
# Role Arn
#-------------------------------------------------------

data "aws_security_group" "alb_sg" {
  name = "${var.cluster}_shared_alb_sg"
}

#--------------------------------------------------------
# Database 
#-------------------------------------------------------

data "aws_ssm_parameter" "db_name" {
  name = "${local.db_ref}.db_name"
}

data "aws_ssm_parameter" "db_username" {
  name = "${local.db_ref}.db_username"
}

data "aws_ssm_parameter" "db_password" {
  name = "${local.db_ref}.db_password"
}

data "aws_ssm_parameter" "db_host" {
  name = "${var.cluster}.db_host"
}

data "aws_ssm_parameter" "dns_zone" {
  name = "${var.cluster}.dns_zone"
}

data "aws_ssm_parameter" "ssl_cert_region" {
  name = "${var.cluster}.ssl_cert_region"
}

data "aws_ssm_parameter" "state_bucket" {
  name = "${var.cluster}.state_bucket"
}

data "aws_ssm_parameter" "config_root" {
  name = "${var.cluster}.config_root"
}

data "aws_vpc" "cluster" {
  tags = {
    Name = "${var.cluster}-vpc"
  }
}

data "aws_subnet" "a" {
  vpc_id = "${data.aws_vpc.cluster.id}"

  tags {
    Name = "${var.cluster}-vpc-public-${var.aws_region}a"
  }
}

data "aws_subnet" "b" {
  vpc_id = "${data.aws_vpc.cluster.id}"

  tags {
    Name = "${var.cluster}-vpc-public-${var.aws_region}b"
  }
}

data "aws_subnet" "c" {
  vpc_id = "${data.aws_vpc.cluster.id}"

  tags {
    Name = "${var.cluster}-vpc-public-${var.aws_region}c"
  }
}
