#!/bin/bash

# Get required code
mkdir -p assets/code
cp ../../../indexer/ls_s2_cog.py assets/

# Run docker
docker build -f index-Dockerfile -t geoscienceaustralia/datacube-wms:aux_index .
