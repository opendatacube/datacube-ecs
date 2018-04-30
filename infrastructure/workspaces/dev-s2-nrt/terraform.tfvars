# The cluster you created using terraform-ecs
cluster = "default"

# The name of your project
workspace = "dev-s2-nrt"

# The number of containers to run at once
task_desired_count = 2

# The name of the database server
database = "default-dev-mydb-rds"

# The name of the service
name = "datacube-wms"

# The docker image to deploy
docker_image = "opendatacube/wms:latest"
