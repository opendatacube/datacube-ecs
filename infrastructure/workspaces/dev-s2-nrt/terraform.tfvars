# The cluster you created using terraform-ecs
cluster = "datacube-dev"

# The name of your project
workspace = "dev-s2-nrt"

# The number of containers to run at once
task_desired_count = 50

# The name of the database
database = "datacube-dev.nrtprod"

# The name of the service
name = "datacube-wms"

# The docker image to deploy
docker_image = "opendatacube/wms:latest"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 4 --timeout 300 datacube_wms.wsgi"

environment_vars = {
  "WMS_CONFIG_URL" = "https://raw.githubusercontent.com/opendatacube/datacube-ecs/master/infrastructure/workspaces/dev-s2-nrt/wms_cfg.py"
}

# DNS address for the WMS service
dns_name = "nrt.deawms.gadevs.ga"

# DNS zone for WMS service
dns_zone = "deawms.gadevs.ga"

# Memory for each container
memory = 1536
