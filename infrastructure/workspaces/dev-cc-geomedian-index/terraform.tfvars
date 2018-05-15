# The cluster you created using terraform-ecs
cluster = "datacube-prod"

# The name of your project
workspace = "dev-cc-geomedian-index"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "datacube-prod.geomprod"

# The name of the service
name = "datacube-wms-index"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_index"

# environment variables configuring the docker container
environment_vars = {
  "DC_S3_INDEX_BUCKET" = "dea-public-data"
  "DC_S3_INDEX_PREFIX" = "ewater/cambodia_cube"
  "WMS_CONFIG_URL"     = "https://raw.githubusercontent.com/harshurampur/datacube-wms/master/datacube_wms/wms_cfg.py"

}

schedulable = true

schedule_expression = "cron(1 0 * * ? *)"
