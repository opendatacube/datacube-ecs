# The name of your project
workspace = "geomedian-au-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

memory = 512

database_task = true

new_database_name = "geomedian-au"

# The name of the service
name = "datacube-wms-g-au-db"

# The docker image to deploy
docker_image = "opendatacube/wms:setup"

environment_vars = {
  "PRODUCT_URLS" = "raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/develop/digitalearthau/config/products/geomedian_nbart_annual.yaml"
}
