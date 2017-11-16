#!/bin/bash
source $HOME/.profile

cd datacube-wms/datacube_wms
export FLASK_APP=wms.py
python -m flask run -h 0.0.0.0 -p 80
