#!/bin/bash
datacube system init --no-default-types --no-init-users

datacube metadata_type add metadata-types.yaml

PGPASSWORD=$DB_PASSWORD psql -d $DB_DATABASE \
     -h $DB_HOSTNAME \
     -p $DB_PORT \
     -U $DB_USERNAME \
     -f datacube-wms/create_tables.sql
