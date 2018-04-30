# datacube-ecs
Runs Datacube as a service on an AWS EC2 Container Service Cluster

## Requirements
Required software:
`docker`
`terraform`


Required steps:
* This repo expects you to have built an ecs cluster using [terraform-ecs](https://github.com/GeoscienceAustralia/terraform-ecs)


Recommended software
`awslogs`


## Docker Containers
We use the standard OpenDataCube containers defined [here](https://github.com/opendatacube/docker-images)

## Installation

### Change


### Configuration
 * Create a new folder in infrastructure/workspaces
 * Copy the contents of another service and change the variables to suit
 * In `backend.cfg`
    * `bucket=$bucket` Should be an S3 bucket in your AWS Account
    * `key=$cluster/$workspace/terraform.tfvars` Should match the cluster and directory name
    * `region=$region` The region your S3 bucket lives in
    * `dynamodb_table=$table` A table configured to act as a state lock
 * In `terraform.tfvars`
    * `cluster = $clustername` Should match the cluster you created using [terraform-ecs](https://github.com/GeoscienceAustralia/terraform-ecs)
    * `workspace = $workspacename` Unique name for this service on the cluster
    * `task_desired_count = $taskcount` Number of ECS tasks to run

### Creating
 * `export WORKSPACE=$workspace`
 * `cd infrastructure`
 * `terraform init -backend-config workspaces/$WORKSPACE/backend.cfg`
 * `terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE`
 * `terraform plan -var-file="workspaces/$WORKSPACE/terraform.tfvars`
 * `terraform apply -var-file="workspaces/$WORKSPACE/terraform.tfvars"`

### Monitor logs
 * `awslogs get $cluster/$workspacename/$name --watch`
 * i.e. `awslogs get default/indexing/datacube-wms --watch`

### Destroying
 * `terraform destroy -f`


