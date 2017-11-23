#!/bin/bash
source $HOME/.profile

aws s3 cp s3://dea-public-data/LS8_OLI_NBART/ls8_nbart_albers.json /opt/data/LS8_OLI_NBART/
aws s3 cp s3://dea-public-data/LS8_OLI_PQ/ls8_pq_albers.json /opt/data/LS8_OLI_PQ/

TARGET_DATA=(
  "LS8_OLI_NBART/12_-48/LS8_OLI_NBART_3577_12_-48_20170929234644000000_v1508468655.nc"
  "LS8_OLI_NBART/12_-48/LS8_OLI_NBART_3577_12_-48_20170927235905000000_v1508468655.nc"
  "LS8_OLI_NBART/12_-48/LS8_OLI_NBART_3577_12_-48_20170927235841000000_v1508468655.nc"
  "LS8_OLI_NBART/12_-48/LS8_OLI_NBART_3577_12_-48_20170920235251000000_v1508468655.nc"
  "LS8_OLI_NBART/12_-48/LS8_OLI_NBART_3577_12_-48_20170920235227000000_v1508468655.nc"
)

for i in "${TARGET_DATA[@]}"
do
	aws s3 cp "s3://dea-public-data/$i" "/opt/data/$i"
done

datacube system init --no-default-types --no-init-users

export PGPASSWORD=$DB_PASSWORD

psql -d $DB_DATABASE \
     -h $DB_HOSTNAME \
     -p $DB_PORT \
     -U $DB_USERNAME \
     -f $HOME/datacube-wms/create_tables.sql

wget https://raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/develop/digitalearthau/config/metadata-types.yaml
datacube metadata_type add metadata-types.yaml

datacube product add /opt/data/LS8_OLI_NBART/ls8_nbart_albers.json
datacube product add /opt/data/LS8_OLI_PQ/ls8_pq_albers.json

# Add to bucket in future
wget https://raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/develop/digitalearthau/config/products/ls8_scenes.yaml
datacube product add ls8_scenes.yaml

shopt -s globstar
datacube dataset add /opt/data/**/*.nc

python $HOME/datacube-wms/update_ranges.py
