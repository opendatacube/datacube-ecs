#!/bin/bash
source $HOME/.profile

cd datacube-wms/datacube_wms
export FLASK_APP=wms.py
python -m flask run -p 80
