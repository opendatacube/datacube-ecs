#--------------------------------------------------------------
# Account ID
#--------------------------------------------------------------

# Get the AWS account ID so we can use it in IAM policies

data "aws_caller_identity" "current" {}