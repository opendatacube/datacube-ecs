#!/usr/bin/env bash
echo "Dry Running $1"

pushd infrastructure
rm -rf .terraform
export WORKSPACE=$1
terraform init -backend-config workspaces/$WORKSPACE/backend.cfg
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE
terraform plan -input=false -var-file="workspaces/$WORKSPACE/terraform.tfvars" -out $WORKSPACE-dry-run.plan
rm $WORKSPACE-dry-run.plan
popd
