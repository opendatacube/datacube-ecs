#!/usr/bin/env bash

# Get required code
# Get required code
mkdir -p assets/code
cp ../../../indexer/ls_s2_cog.py assets/

# Run docker
docker build -f archive-Dockerfile -t geoscienceaustralia/datacube-wms:aux_archive .