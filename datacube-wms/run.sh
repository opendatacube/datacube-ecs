#!/bin/bash
source $HOME/.profile

cd datacube-wms/datacube_wms

gunicorn -w 4 -b 0.0.0.0:80 wms:app
