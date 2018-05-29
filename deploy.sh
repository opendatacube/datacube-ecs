#!/usr/bin/env bash
profile=${2:-"default"}

echo "Deploying $1 as $profile"

pushd infrastructure
rm -rf .terraform
export WORKSPACE=$1
export AWS_PROFILE="$profile"
terraform init -backend-config backend-dev.cfg
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE
terraform plan-input=false -var-file="workspaces/$WORKSPACE/terraform.tfvars" -var 'cluster=datacube-dev'
terraform apply -auto-approve -input=false -var-file="workspaces/$WORKSPACE/terraform.tfvars" -var 'cluster=datacube-dev'
unset WORKSPACE
unset AWS_PROFILE
popd
