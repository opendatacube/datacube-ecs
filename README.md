# datacube-ecs
EC2 Container Service for Datacube

Installation
Requires software:
`docker`
`docker-compose`



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
    * Install `golang` tools
    * `go get github.com/segmentio/chamber'
    * `export GOOS=linux; export GOARCH=amd64; go build github.com/segmentio/chamber`
    * Move the created `chamber` binary to the `datacube-wms` folder
#### Building
    * Run `docker build -t $username/datacube-wms:$tag .`

## Main Terraform
### Pre-Terraform Steps
    * Install `golang` tools
    * `go get github.com/segmentio/chamber'
    * `chamber write datacube-wms db_password $DB_PASSWORD`

### `main.tf`
#### Creating
    * `terraform init`
    * Existing Cloudwatch Log Groups to use?
        * `terraform-ecs/scripts/manage_cloudwatch.sh import ec2_instances`
    * `export TF_VAR_db_admin_password=$DB_PASSWORD`
    * `export TF_VAR_parameter_store_key_arn=$ARN`
    * terraform plan -out wms.plan`
    * `terraform apply wms.plan`
#### Destroying
    * Need to keep Cloudwatch Log Groups?
        * `terraform-ecs/scripts/manage_cloudwatch.sh rm ec2_instances`
    * `terraform destroy`


