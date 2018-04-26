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
