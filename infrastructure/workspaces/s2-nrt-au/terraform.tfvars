# The cluster you created using terraform-ecs
cluster = "datacube-dev"

# The name of your project
workspace = "s2-nrt-au"

# Setting this to false will turn off auto-restart and web access
webservice = true

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "datacube-dev.nrtau"

# The name of the service
name = "datacube-wms-s2-au"

docker_image = "opendatacube/wms:latest"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 60 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL"     = "https://raw.githubusercontent.com/opendatacube/datacube-ecs/s2-au/infrastructure/workspaces/s2-nrt-au/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "nrt-au.wms.gadevs.ga"

# DNS zone for WMS service
dns_zone = "wms.gadevs.ga"

# Memory for each container
memory = 2048

alb_name = "s2-nrt-au"

enable_https = true

ssl_cert_domain_name = "*.wms.gadevs.ga"

ssl_cert_region = "ap-southeast-2"

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
