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

data "aws_ssm_parameter" "db_username" {
  name = "${var.database}.db_username"
}

data "aws_ssm_parameter" "db_password" {
  name = "${var.database}.db_password"
}

data "aws_ssm_parameter" "db_host" {
  name = "${var.cluster}.db_host"
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
