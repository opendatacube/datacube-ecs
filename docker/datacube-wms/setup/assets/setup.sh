#!/bin/bash

PGPASSWORD=$DB_PASSWORD createdb \
    -h $DB_HOSTNAME \
    -p $DB_PORT \
    -U $DB_USERNAME \
    $DB_DATABASE

datacube system init --no-default-types --no-init-users

datacube metadata_type add firsttime/metadata-types.yaml

PGPASSWORD=$DB_PASSWORD psql \
    -d $DB_DATABASE \
    -h $DB_HOSTNAME \
    -p $DB_PORT \
    -U $DB_USERNAME \
    -f create_tables.sql
