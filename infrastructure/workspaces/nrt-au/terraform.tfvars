# The name of your project
workspace = "s2-nrt-au"

# Setting this to false will turn off auto-restart and web access
webservice = true

# The number of containers to run at once
task_desired_count = 40

# The name of the database
database = "nrtau"

# The name of the service
name = "datacube-wms-s2-au"

docker_image = "opendatacube/wms:0.2.4"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 60 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL" = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/prod/services/wms/nrt-au/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "nrt-au"

# Memory for each container
memory = 2048

alb_name = "s2-nrt-au"

enable_https = true

ssl_cert_region = "ap-southeast-2"

use_cloudfront = true
