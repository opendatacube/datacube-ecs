# The name of your project
workspace = "dev-cc-geomedian"

# The number of containers to run at once
task_desired_count = 50

# The name of the database
database = "geomedianprod"

# The name of the service
name = "datacube-wms-geom"

# The docker image to deploy
docker_image = "opendatacube/wms:1.5.4"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 300 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL" = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/prod/services/wms/cc-geomedian/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "geomedian"

# Memory for each container
memory = 1536

alb_name = "geomedian"

enable_https = true

ssl_cert_region = "ap-southeast-2"
