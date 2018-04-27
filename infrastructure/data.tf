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
  name = "${var.cluster}.db_username"
}

data "aws_ssm_parameter" "db_username" {
  name = "${var.cluster}.db_username"
}

data "aws_ssm_parameter" "db_password" {
  name = "${var.cluster}.db_password"
}

data "aws_ssm_parameter" "db_host" {
  name = "${var.cluster}.db_host"
}
