#!/usr/bin/env bash
profile=${2:-"default"}

echo "Dry Running $1 as $profile"

pushd infrastructure
rm -rf .terraform
export WORKSPACE="$1"
export AWS_PROFILE="$profile"
terraform init -backend-config backend-dev.cfg
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE
terraform plan -input=false -var-file="workspaces/$WORKSPACE/terraform.tfvars" -var 'cluster=datacube-dev' -out $WORKSPACE-dry-run.plan
rm $WORKSPACE-dry-run.plan
unset WORKSPACE
unset AWS_PROFILE
popd
