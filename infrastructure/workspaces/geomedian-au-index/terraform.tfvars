# The name of your project
workspace = "geomedian-au-index"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "geomedian-au"

# The name of the service
name = "datacube-wms-au-index"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_index"

# environment variables configuring the docker container
environment_vars = {
  "DC_S3_INDEX_BUCKET" = "dea-public-data"
  "DC_S3_INDEX_PREFIX" = "Geomedian-AU/test_folder/"
  "DC_S3_INDEX_SUFFIX" = ".yaml"
  "WMS_CONFIG_URL"     = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/dev/services/wms/geomedian-au/wms_cfg.py"
}

schedulable = true

memory = 16384

schedule_expression = "cron(1 0 * * ? *)"
