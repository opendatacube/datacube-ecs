# The name of your project
workspace = "s2-nrt-au-archive"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database
database = "nrtau"

# The name of the service
name = "datacube-wms-s2-au-archive"

# The docker image to deploy
docker_image = "opendatacube/wms:archive"

# environment variables configuring the docker container
environment_vars = {
  "DC_S3_ARCHIVE_BUCKET" = "dea-public-data"
  "DC_S3_ARCHIVE_PREFIX" = "L2/sentinel-2-nrt/S2MSIARD/"
  "DC_S3_ARCHIVE_SUFFIX" = "ARD-METADATA.yaml"
  "DC_ARCHIVE_DAYS"      = 31
  "WMS_CONFIG_URL"       = "https://raw.githubusercontent.com/GeoscienceAustralia/dea-config/master/prod/services/wms/nrt-au/wms_cfg.py"
}

schedulable = true

schedule_expression = "cron(1 13 * * ? *)"
