# The cluster you created using terraform-ecs
cluster = "datacube-prod"

# The name of your project
workspace = "dev-s2-nrt-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# Set if this is a database setup task
database_task = true

new_database_name = "nrtprod"

# The number of containers to run at once
task_desired_count = 1

memory = 512

# The name of the service
name = "datacube-wms-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

environment_vars = {
  "PRODUCT_URLS" = "raw.githubusercontent.com/opendatacube/datacube-ecs/master/indexer/ls_nrt_products.yaml:raw.githubusercontent.com/opendatacube/datacube-ecs/master/indexer/s2_nrt_products.yaml"
}
