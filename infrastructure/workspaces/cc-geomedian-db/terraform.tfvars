# The name of your project
workspace = "dev-cc-geomedian-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

memory = 512

database_task = true

new_database_name = "geomedianprod"

# The name of the service
name = "datacube-wms-geom-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

environment_vars = {
  "PRODUCT_URLS" = "raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/config-geomedian/digitalearthau/config/cambodia/geomed_product.yaml:raw.githubusercontent.com/opendatacube/datacube-core/develop/docs/config_samples/dataset_types/ls_usgs_sr_scene.yaml"
}
