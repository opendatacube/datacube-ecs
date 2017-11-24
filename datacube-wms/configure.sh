#!/bin/bash
source $HOME/.profile

set -eu
set -x

export CONF_FILE="$HOME/.datacube.conf"

# Build Config file
echo "[datacube]" > $CONF_FILE 
echo "db_hostname: $DB_HOSTNAME" >> $CONF_FILE 
echo "db_database: $DB_DATABASE" >> $CONF_FILE 
echo "db_username: $DB_USERNAME" >> $CONF_FILE 
echo "db_password: $DB_PASSWORD" >> $CONF_FILE
echo "db_port: $DB_PORT" >> $CONF_FILE

# Set the Public URL
# TODO: Fix config file
WMS_CONFIG_FILE="$HOME/datacube-wms/datacube_wms/wms_cfg.py"
echo 'import os' >> $WMS_CONFIG_FILE
echo 'default_url = "http://localhost:5000/"' >> $WMS_CONFIG_FILE
echo 'service_cfg["url"] = os.environ.get("PUBLIC_URL", default_url)' >> $WMS_CONFIG_FILE
