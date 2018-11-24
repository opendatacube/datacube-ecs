# Datacube ECS

:warning: This repository is no longer being actively maintained, you should consider using our kubernetes helm charts instead [datacube-charts](https://github.com/opendatacube/datacube-charts/) - if you want to take over the maintenance of this repo please get in touch via slack.opendatacube.org :warning:


[![Build Status](https://travis-ci.org/GeoscienceAustralia/terraform-ecs.svg?branch=master)](https://travis-ci.org/GeoscienceAustralia/terraform-ecs)

This repository contains the Terraform modules for creating a production ready ECS app in AWS [terraform-ecs](https://github.com/GeoscienceAustralia/terraform-ecs) to define the base ECS cluster.

* [Requirements](#requirements)
  * [Local System Requirements](#local-system-requirements)
  * [AWS Environment Requirements](#aws-environment-requirements)
* [Config](#config)
  * [Backend Config](#backend-config)
  * [Terraform Variables](#terraform-variables)
* [Create It](#Create-it)
* [Information](#information)
  * [What is ECS](#what-is-ecs)
  * [ECS Infrastructure](#ecs-infrastructure)
  * [Terraform Module](#terraform-module)
  * [SSH Access to the Instances](#ssh-access-to-the-instances)
  * [Logging](#logging)
  * [EC2 node security and updates](#ec2-node-security-and-updates)
* License(#license)
* Contacts(#contacts)

## Requirements

### Local system Requirements
* terraform > v0.10.0
* docker
* ecs-cli > 1.0.0 (bda91d5)
* awslogs (recommended)

### AWS Environment requirements
* An ECS cluster deployed using [terraform-ecs](https://github.com/GeoscienceAustralia/terraform-ecs)


## Config
To separate the config for your applications you should create a new folder in the infrastructure/workspaces folder for each application.
This folder should include: 
* backend.cfg
* terraform.tfvars

### Backend Config
To enable separation between dev and prod infrastructure we use two different backend config files `backend-dev.cfg` and `backend-prod.cfg`. This will define the base terraform state file.

```
bucket="ga-aws-dea-dev-tfstate"
key = "datacube-dev/terraform.tfstate"
region = "ap-southeast-2"
dynamodb_table = "terraform"
```

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket | The S3 bucket to be used to store terraform state files | string | `` | yes |
| key | The path of the statefile within the bucket | string | `` | yes |
| region | The region of the bucket | string | `` | yes |
| dynamodb_table | A DynamoDB table with the primary key : LockID, used to lock modifications to the statefile | string | `` | yes |

### Terraform Variables

The cluster requires a number of variables to be defined in the `terraform.tfvars` file, these variables are defined below.

Example jobs are provided to:
- initialise the database
- run index once
- run index on a schedule
- run archive on a scedule
- run wms as a service

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_name | The name of the loadbalancer to create | string | `default` | no |
| aws_region | The region you are deploying in | string | `ap-southeast-2` | no |
| cluster | The name of the cluster you created using the terraform-ecs repo | string | `datacube-wms` | no |
| container_port | The port our container is listening on | string | `8000` | no |
| custom_policy | IAM Policy JSON to be added to the task policy | string | `` | no |
| database | The name of the database | string | `` | no |
| database_task | Whether we should create a database and initialise datacube | string | `false` | no |
| dns_name | DNS name of the service | string | `` | no |
| dns_zone | Overwrites the cluster DNS zone | string | `` | no |
| docker_command | Command to run on docker container | string | `` | no |
| docker_image | A docker image to run | string | - | yes |
| enable_https | Should HTTPS be enabled (and forced) | string | `false` | no |
| environment_vars | Map containing environment variables to pass to docker container. Overrides defaults. | string | `<map>` | no |
| health_check_path | A path that returns 200 OK if container is healthy | string | `/?version=1.3.0&request=GetCapabilities&service=WMS` | no |
| memory | Memory for the container in MB | string | `1024` | no |
| name | Name of the service | string | - | yes |
| new_database_name | If this is a datasbase task we will create a new db with this name | string | `` | no |
| owner | The name of the team that manages this service - used to tag resources | string | `DEA` | no |
| schedulable | Should this task be run on a regular schedule | string | `false` | no |
| schedule_expression | AWS Cron or Rate expression | string | `` | no |
| ssl_cert_domain_name | Overwrites the cluster default wildcard cert | string | `` | no |
| ssl_cert_region | If SSL is enabled, the region the certificates exist in | string | `us-east-1` | no |
| task_desired_count | The number of tasks we want to run | string | `1` | no |
| webservice | Whether the task should restart and be publically accessible | string | `true` | no |
| workspace | The name of this workspace - used to seperate resources | string | `dev` | no |

## Outputs

| Name | Description |
|------|-------------|
| db |  |
| wms_endpoint |  The dns endpoint (if applicable) |

## Docker Containers
We use the standard OpenDataCube containers defined [here](https://github.com/opendatacube/docker-images)

### Customisations

**Aux_Setup**

Based on OpenDataCube WMS, Adds terraform and scripts to create a database and store the credentials in parameter store. 

**Indexing**

Based on OpenDataCube WMS, Adds indexing script

**Archive** 

Based on OpenDataCube WMS, Archives old data from database (enables a rolling index of data)

## Installation

### Change

### Creating
 * Setup DB
   `./deploy.sh nrt-db`
 * Create Index
   `./deploy.sh rt-index`
 * Deploy WMS
   `./deploy.sh nrt`


### Monitor logs
 * `awslogs get $cluster/apps/$workspacename --watch`
 * i.e. `awslogs get datacube-prod/apps/nrt-db --watch`

## Destroying
 * `terraform init backend-dev.cfg`
 * `terraform workspace select nrt`
 * `terraform destroy -f`


