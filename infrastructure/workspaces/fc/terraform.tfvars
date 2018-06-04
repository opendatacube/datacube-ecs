# The name of your project
workspace = "fc"

# The number of containers to run at once
task_desired_count = 1

# The name of the database that we will pass credentials to
database = "fc"

# The name of the service
name = "datacube-wps"

# The docker image to deploy
docker_image = "opendatacube/wps:latest"

# Command to run on the container
docker_command = "gunicorn -b 0.0.0.0:8000 -w 1 --timeout 60 pywps_app:application"

alb_name = "fc"

# DNS address for the WMS service
dns_name = "fc"

ssl_cert_region = "ap-southeast-2"

health_check_path = "/wps "

# Memory for each container
memory = 2048

enable_https = true
