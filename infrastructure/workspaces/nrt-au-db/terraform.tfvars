# The name of your project
workspace = "s2-nrt-au-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# Set if this is a database setup task
database_task = true

new_database_name = "nrtau"

# The number of containers to run at once
task_desired_count = 1

memory = 512

# The name of the service
name = "datacube-wms-s2-au-db"

# The docker image to deploy
docker_image = "opendatacube/wms:setup"

environment_vars = {
  "PRODUCT_URLS" = "raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/prod/products/nrt/sentinel/products.yaml"
}
