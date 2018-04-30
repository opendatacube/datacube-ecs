#!/bin/bash

# Get required files
mkdir -p assets/code
wget -N https://raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/develop/digitalearthau/config/metadata-types.yaml -P assets/code/

docker build -f setup-Dockerfile -t geoscienceaustralia/datacube-wms-setup:latest .
