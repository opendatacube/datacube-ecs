#!/bin/bash

# Get required code
mkdir -p assets/code
git clone --depth 1 https://github.com/opendatacube/datacube-core.git -b develop assets/code
cp assets/code/ingest/s3_indexing/sentinel_2/ls_s2_cog.py assets/

# Run docker
docker build -f index-Dockerfile -t geoscienceaustralia/datacube-wms-index:aux_index .