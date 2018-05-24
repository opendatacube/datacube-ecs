# The cluster you created using terraform-ecs
cluster = "datacube-dev"

# The name of your project
workspace = "s2-nrt-au-index"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "datacube-dev.nrtau"

# The name of the service
name = "datacube-wms-s2-au-index"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_index"

# environment variables configuring the docker container
environment_vars = {
  "DC_S3_INDEX_BUCKET" = "dea-public-data"
  "DC_S3_INDEX_PREFIX" = " "
  "DC_S3_INDEX_SUFFIX" = "ARD-METADATA.yaml"
  "WMS_CONFIG_URL"     = "https://raw.githubusercontent.com/opendatacube/datacube-ecs/master/infrastructure/workspaces/s2-nrt-au/wms_cfg.py"
}

schedulable = true

schedule_expression = "cron(1 14 * * ? *)"

custom_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetFiles",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListObjects",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::dea-public-data",
                "arn:aws:s3:::dea-public-data/*"
            ]
        }
    ]
}
EOF
