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
 * In `terraform.tfvars`
    * `cluster = $clustername` Should match the cluster you created using [terraform-ecs](https://github.com/GeoscienceAustralia/terraform-ecs)
    * `workspace = $workspacename` Unique name for this service on the cluster
    * `task_desired_count = $taskcount` Number of ECS tasks to run

### Creating
 * `terraform init`
 * `terraform plan`
 * `terraform apply`

### Monitor logs
 * `awslogs get $cluster/$workspacename/$name --watch`
 * i.e. `awslogs get default/indexing/datacube-wms --watch`

### Destroying
 * `terraform destroy -f`


