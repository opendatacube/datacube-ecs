#!/bin/bash
source $HOME/.profile

conda install scikit-image flask

git clone https://github.com/opendatacube/datacube-wms.git

cd datacube-wms

pip install -e .

export PGPASSWORD=$DB_PASSWORD

psql -d $DB_DATABASE \
     -h $DB_HOSTNAME \
     -p $DB_PORT \
     -U $DB_USERNAME \
     -f create_tables.sql
