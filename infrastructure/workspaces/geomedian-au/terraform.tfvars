# The name of your project
workspace = "geomedian-au"

# The number of containers to run at once
task_desired_count = 20

# The name of the database
database = "geomedian-au"

# The name of the service
name = "datacube-wms-g-au"

# The docker image to deploy
docker_image = "opendatacube/wms:0.2.5"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 300 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL" = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/geomedian-au/dev/services/wms/geomedian-au/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "geomedianau"

# Memory for each container
memory = 16384 

alb_name = "geomedianau"

enable_https = true

ssl_cert_region = "ap-southeast-2"
