#!/bin/bash
source $HOME/.profile

conda install scikit-image flask gunicorn

git clone https://github.com/opendatacube/datacube-wms.git

cd datacube-wms
pip install -e .
