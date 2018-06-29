#!/usr/bin/env bash
if [ ! -d "infrastructure/workspaces/$1" ]
then
    echo "Could not find workspace directory $1"
    echo "Aborting..."
    exit 1
fi

profile=${2:-"default"}

echo "Dry Running $1 as $profile"

pushd infrastructure
rm -rf .terraform
export WORKSPACE="$1"
export AWS_PROFILE="$profile"
if [ ! -d "workspaces/$WORKSPACE" ]
then
    echo "Could not find workspace directory $WORKSPACE"
    echo "Aborting..."
    exit 1
fi
terraform init -backend-config backend-dev.cfg
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE
terraform plan -input=false -var-file="workspaces/$WORKSPACE/terraform.tfvars" -var 'cluster=datacube-dev' -out $WORKSPACE-dry-run.plan
rm $WORKSPACE-dry-run.plan
popd
