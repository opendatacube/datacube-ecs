#--------------------------------------------------------------
# Account ID
#--------------------------------------------------------------

# Get the AWS account ID so we can use it in IAM policies

data "aws_caller_identity" "current" {}

# The ECS Cluster running the tasks
data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster}"
}