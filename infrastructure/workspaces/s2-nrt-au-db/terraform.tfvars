# The cluster you created using terraform-ecs
cluster = "datacube-dev"

# The name of your project
workspace = "s2-nrt-au-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

memory = 512

# The name of the database
database = "datacube-dev"

# The name of the service
name = "datacube-wms-s2-au-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

environment_vars = {
  TF_VAR_cluster  = "datacube-dev"
  TF_VAR_state_bucket = "ga-aws-dea-dev-tfstate"
  TF_VAR_database = "nrtau"
  "DB_DATABASE"   = "nrtau"
  "DB_PORT"       = "5432"
  "VIRTUAL_HOST"  = "localhost,127.0.0."
  "PRODUCT_URLS"  = "raw.githubusercontent.com/opendatacube/datacube-ecs/master/indexer/s2_nrt_products.yaml"
}

custom_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters",
                "kms:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:DeleteParameters",
                "ssm:PutParameter",
                "ssm:DeleteParameter",
                "ssm:GetParametersByPath"
            ],
            "Resource": [
                "arn:aws:ssm:ap-southeast-2:451924316694:parameter/datacube-dev*",
                "arn:aws:ssm:ap-southeast-2:451924316694:parameter/datacube-dev.nrt*"
            ]
        },
        {
            "Sid": "TerraformState",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::ga-aws-dea-dev-tfstate",
                "arn:aws:s3:::ga-aws-dea-dev-tfstate/*",
                "arn:aws:dynamodb:*:*:table/terraform"
            ]
        }
    ]
}
EOF
