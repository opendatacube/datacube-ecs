# The cluster you created using terraform-ecs
cluster = "default"

# The name of your project
workspace = "dev-s2-nrt-db"

# Setting this to false will turn off auto-restart and web access
webservice = false

# The number of containers to run at once
task_desired_count = 1

# The name of the database server
database = "default-dev-mydb-rds"

# The name of the service
name = "datacube-wms-db"

# The docker image to deploy
docker_image = "geoscienceaustralia/datacube-wms:aux_setup"

# Command to run on the container
docker_command = "/bin/bash -c firsttime/setup.sh"
