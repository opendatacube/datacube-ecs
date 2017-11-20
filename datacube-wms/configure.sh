#!/bin/bash
source $HOME/.profile

export CONF_FILE="$HOME/.datacube.conf"

# Build Config file
echo "[datacube]" > $CONF_FILE 
echo "db_hostname: $DB_HOSTNAME" >> $CONF_FILE 
echo "db_database: $DB_DATABASE" >> $CONF_FILE 
echo "db_username: $DB_USERNAME" >> $CONF_FILE 
echo "db_password: $DB_PASSWORD" >> $CONF_FILE
echo "db_port: $DB_PORT" >> $CONF_FILE


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

WMS_CONFIG_FILE="$HOME/datacube-wms/datacube_wms/wms_cfg.py"
echo 'import os' >> $WMS_CONFIG_FILE
echo 'default_url = "http://localhost:5000/"' >> $WMS_CONFIG_FILE
echo 'service_cfg["url"] = os.environ.get("PUBLIC_URL", default_url)' >> $WMS_CONFIG_FILE

python $HOME/datacube-wms/update_ranges.py
