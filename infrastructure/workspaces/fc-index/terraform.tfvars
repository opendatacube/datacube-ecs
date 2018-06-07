# The name of your project
workspace = "fc-index"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "fc"

# The name of the service
name = "fc-index"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_index"

# environment variables configuring the docker container
environment_vars = {
  "DC_S3_INDEX_BUCKET" = "dea-public-data"
  "DC_S3_INDEX_PREFIX" = "projects/IrrigatedCropping/LS8_FC_cogs/"
  "DC_S3_INDEX_SUFFIX" = ".yaml"
}

schedulable = false
