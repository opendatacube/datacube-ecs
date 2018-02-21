# datacube-ecs
EC2 Container Service for Datacube

Installation
Requires software:
`docker`
`terraform`
`golang`

## Docker Containers
### `docker-compose.yml`
Includes:
 * local postgres server (running on 5432) *TODO: Make private*
 * conda environment
 * datacube install
 * jupyter notebook (running on port 80)
The jupyter notebook will require a token to access it, which is availible from the console output.
This means you will not be able to run `docker-compose` in daemon mode.

### `datacube-wms`
#### Pre docker build steps
 * `go get github.com/segmentio/chamber'
 * `export GOOS=linux; export GOARCH=amd64; go build github.com/segmentio/chamber`
 * Move the created `chamber` binary to the `datacube-wms` folder

#### Docker Build
 * Run `docker build -t $username/datacube-wms:$tag .` (`docker build -t geoscienceaustralia/datacube-wms:latest .`)
 * `docker push $username/datacube-wms:$tag`

## Main Terraform

### Pre-Terraform Steps
 * `go get github.com/segmentio/chamber`
 * `chamber write datacube-wms db_password $DB_PASSWORD` Only required if not previously set, or has changed

### `main.tf`

#### Change
 * At top level add:
    * `cluster = $clustername` Should be a descriptive name for the cluster
    * `workspace = $workspacename` Name for the workspace
    * `key_name` AWS EC2 SSH key for accessing instances
    * `task_desired_count = $taskcount` Number of ECS tasks to run
 * Optional if SSH access required:
    * `ssh_ip_address = $youripaddress` IP addresses that jumpbox will allow connections from
    * `enable_jumpbox = true` Enables jumpbox
 * `docker_registry_image`
    * Change `name` to `$username/datacube-wms:$tag` as set above.

#### Creating
 * `terraform init`
 * Existing Cloudwatch Log Groups to use?
    * `terraform-ecs/scripts/manage_cloudwatch.sh import ec2_instances`
 * `export TF_VAR_db_admin_password=\`chamber read datacube-wms db_password\``
 * `export TF_VAR_parameter_store_key_arn=$ARN`
 * `terraform plan -out wms.plan`
 * `terraform apply wms.plan`

#### Destroying
 * Need to keep Cloudwatch Log Groups?
    * `terraform-ecs/scripts/manage_cloudwatch.sh rm ec2_instances`
 * `terraform destroy`


