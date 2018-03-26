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
 * In `cluster.tfvars`
    * `cluster = $clustername` Should be a descriptive name for the cluster
    * `workspace = $workspacename` Name for the workspace
    * `task_desired_count = $taskcount` Number of ECS tasks to run
 * In `jumpbox.tfvars`
    * `key_name` AWS EC2 SSH key for accessing instances
    * `ssh_ip_address = $youripaddress` IP addresses that jumpbox will allow connections from
    * `enable_jumpbox = true/false` Enables or disables jumpbox jumpbox
 * `docker_registry_image`
    * Change `name` to `$username/datacube-wms:$tag` as set above.

#### Creating
 * `terraform init`
 * Existing Cloudwatch Log Groups to use?
    * `terraform-ecs/scripts/manage_cloudwatch.sh import ec2_instances`
 * Import Parameter store key
    * `terraform import module.ecs_main.module.ecs_policy.aws_kms_key.parameter_store_key $ARN`
 * Import DB Password
    * `chamber read datacube-wms db_password`
    * Copy `Value` field into var `export TF_VAR_db_admin_password=$VALUE`
 * `terraform plan -var-file=cluster.tfvars -var-file=jumpbox.tfvars -out wms.plan`
 * `terraform apply wms.plan`

#### Destroying
 * Need to keep Cloudwatch Log Groups?
    * `terraform-ecs/scripts/manage_cloudwatch.sh rm ec2_instances`
 * Don't try and delete Parameter store key
    * terraform state rm module.ecs_policy.aws_kms_key.parameter_store_key
 * `terraform destroy -var-file=cluster.tfvars -var-file=jumpbox.tfvars`


