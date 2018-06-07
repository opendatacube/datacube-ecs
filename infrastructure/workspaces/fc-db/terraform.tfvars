# The name of your project
workspace = "fc-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# Set if this is a database setup task
database_task = true

new_database_name = "fc"

# The number of containers to run at once
task_desired_count = 1

memory = 512

# The name of the service
name = "fc-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

environment_vars = {
  "PRODUCT_URLS" = "raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/dev/products/fc/ls8_fc_albers.yaml"
}
