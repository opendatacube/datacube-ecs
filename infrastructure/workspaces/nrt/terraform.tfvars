# The name of your project
workspace = "dev-s2-nrt"

# The number of containers to run at once
task_desired_count = 50

# The name of the database that we will pass credentials to
database = "nrtprod"

# The name of the service
name = "datacube-wms"

# The docker image to deploy
docker_image = "opendatacube/wms:mdba"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 60 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL" = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/prod/services/wms/nrt/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "nrt"

ssl_cert_region = "ap-southeast-2"

# Memory for each container
memory = 2048

enable_https = true
