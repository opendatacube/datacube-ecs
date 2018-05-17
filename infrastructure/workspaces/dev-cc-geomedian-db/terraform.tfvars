# The cluster you created using terraform-ecs
cluster = "datacube-prod"

# The name of your project
workspace = "dev-cc-geomedian-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

memory = 512

# The name of the database
database = "datacube-prod"

# The name of the service
name = "datacube-wms-geom-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

environment_vars = {
  TF_VAR_cluster  = "datacube-prod"
  TF_VAR_database = "geomedianprod"
  "DB_DATABASE"   = "geomedianprod"
  "DB_PORT"       = "5432"
  "VIRTUAL_HOST"  = "localhost,127.0.0."
  "PRODUCT_URLS"  = "raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/config-geomedian/digitalearthau/config/cambodia/geomed_product.yaml:raw.githubusercontent.com/opendatacube/datacube-core/develop/docs/config_samples/dataset_types/ls_usgs_sr_scene.yaml"
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
                "arn:aws:ssm:ap-southeast-2:538673716275:parameter/datacube-prod*",
                "arn:aws:ssm:ap-southeast-2:538673716275:parameter/datacube-prod.geomedian*"
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
                "arn:aws:s3:::dea-devs-tfstate",
                "arn:aws:s3:::dea-devs-tfstate/*",
                "arn:aws:dynamodb:*:*:table/terraform"
            ]
        }
    ]
}
EOF
